# Insurs Online API Integration Guide (Node/Express)

## Overview

Insurs Online is a travel insurance API that lets you calculate prices, create insurance contracts, confirm them after payment, and retrieve policy PDF documents.

**Base URL:** `https://api.insurs.net/b1`

**Authentication:** All requests include an `api_key` field in the JSON body.

**Method:** All endpoints use `POST` with `Content-Type: application/json`.

---

## Environment Variables

```env
INSURS_ONLINE_API_KEY=your_api_key_here
INSURS_ONLINE_BASE_URL=https://api.insurs.net/b1
```

---

## Fixed Constants

These values are assigned to your account and do not change:

| Constant       | Value | Description                    |
|----------------|-------|--------------------------------|
| `product_id`   | `1`   | Insurance product              |
| `company_id`   | `366` | Insurance company              |
| `franchise_id` | `1`   | Deductible tier (standard)     |

---

## Coverage Tiers

| `coverage_id` | Tariff Name | Coverage Amount | Example Price (14-day Schengen) |
|---------------|-------------|-----------------|--------------------------------|
| `1`           | Standard    | $35,000 USD     | $22.50                         |
| `2`           | Advanced    | $100,000 USD    | $30.00                         |
| `3`           | Standard    | $500,000 USD    | $45.00                         |

---

## Locality Coverage IDs

The `locality_coverage` field is an **array of integers**. Common values:

| ID    | Region                    |
|-------|---------------------------|
| `208` | Europe (Schengen)         |
| `237` | Worldwide / Other regions |

---

## Integration Flow

```
1. get_price       -> Get quote with tariff_id + price
2. add_contract    -> Create contract (returns order_id + police_num)
3. [User pays]
4. confirm_contract -> Confirm after payment
5. get_print_form  -> Download policy PDF
```

---

## API Endpoints

### 1. Calculate Price (`/services/api/get_price`)

Get a price quote. Returns a `tariff_id` you'll need for contract creation.

**Request:**

```json
{
  "api_key": "YOUR_API_KEY",
  "product_id": 1,
  "company_id": 366,
  "country_of_departure": "NG",
  "country_of_arrive": "DE",
  "locality_coverage": [208],
  "additional_services": [0],
  "params": {
    "date_from": "2026-03-01",
    "date_to": "2026-03-15",
    "coverage_id": 2,
    "franchise_id": 1,
    "type_of_travel": 1,
    "currency": "USD",
    "tourists": [
      { "date_birth": "1990-01-01" }
    ]
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "tariff_id": 2,
      "tariff_name": "Advanced",
      "total_amount": "30.00",
      "currency": "USD"
    }
  ]
}
```

**Key fields:**
- `country_of_departure` / `country_of_arrive` — ISO 2-letter country codes
- `locality_coverage` — **must be an array**, e.g. `[208]`
- `additional_services` — `[0]` = default (with deductible), `[1]` = no deductible
- `type_of_travel` — `1` = Calm (standard travel)
- `tourists` — array of travelers, only `date_birth` needed for pricing

---

### 2. Create Contract (`/services/api/add_contract`)

Creates an insurance contract/proposal. Call this **before** the user pays.

**Request:**

```json
{
  "api_key": "YOUR_API_KEY",
  "product_id": 1,
  "company_id": 366,
  "tariff_id": 2,
  "country_of_departure": "NG",
  "country_of_arrive": "DE",
  "locality_coverage": [208],
  "insurer": {
    "first_name": "JOHN",
    "last_name": "DOE",
    "phone": "2348012345678",
    "email": "john.doe@example.com",
    "date_birth": "1990-01-01",
    "passport": "A12345678"
  },
  "tourists": [
    {
      "first_name": "JOHN",
      "last_name": "DOE",
      "date_birth": "1990-01-01",
      "passport": "A12345678"
    }
  ],
  "params": {
    "date_from": "2026-03-01",
    "date_to": "2026-03-15",
    "coverage_id": 2,
    "franchise_id": 1,
    "currency": "USD"
  }
}
```

**Response:**

```json
{
  "success": true,
  "order_id": 212330,
  "police_num": "212330",
  "total_amount": "30.00",
  "currency": "USD"
}
```

**Important:** Save `order_id` and `police_num` from this response. The `police_num` is the policy number.

---

### 3. Confirm Contract (`/services/api/confirm_contract`)

Confirm the contract after payment is received.

**Request:**

```json
{
  "api_key": "YOUR_API_KEY",
  "product_id": 1,
  "order_id": 212330,
  "payment_id": -1
}
```

**Response:**

```json
{
  "success": true,
  "order_id": 212330
}
```

**Important:** This response does NOT return `police_num`. Use the one from `add_contract`. Pass `-1` for `payment_id` if you handle payments externally.

---

### 4. Get Policy PDF (`/services/api/get_print_form`)

Retrieve the insurance policy document as a PDF.

**Request:**

```json
{
  "api_key": "YOUR_API_KEY",
  "product_id": 1,
  "order_id": 212330
}
```

**Response:** Raw PDF binary data (~290KB). Content starts with `%PDF-1.4`. Save directly to a file or attach to storage.

---

### 5. Cancel Contract (`/services/api/cancel`)

Cancel a contract. Note: this endpoint may be temporarily unavailable.

**Request:**

```json
{
  "api_key": "YOUR_API_KEY",
  "product_id": 1,
  "order_id": 212330
}
```

**Response (success):**

```json
{
  "success": true
}
```

---

## Error Response Format

All endpoints return errors in this format:

```json
{
  "success": false,
  "error_code": 101,
  "text_error": "Description of what went wrong"
}
```

HTTP status codes: `400` (bad request), `401/403` (auth failure), `429` (rate limit), `500+` (server error).

---

## Node/Express Implementation

### 1. Install Dependencies

```bash
npm install axios express dotenv
```

### 2. API Client (`services/insursOnlineClient.js`)

```js
const axios = require('axios');

const BASE_URL = process.env.INSURS_ONLINE_BASE_URL || 'https://api.insurs.net/b1';
const API_KEY = process.env.INSURS_ONLINE_API_KEY;

async function post(endpoint, params = {}) {
  try {
    const response = await axios.post(`${BASE_URL}${endpoint}`, {
      ...params,
      api_key: API_KEY,
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 30000,
    });

    const data = response.data;

    if (data.success === false || data.error) {
      return {
        success: false,
        data: data.data || null,
        error: data.text_error || data.error || 'Unknown API error',
        errorCode: data.error_code,
      };
    }

    return { success: true, data, error: null };
  } catch (err) {
    if (err.response) {
      return {
        success: false,
        data: null,
        error: `HTTP ${err.response.status}: ${err.response.statusText}`,
      };
    }
    return { success: false, data: null, error: err.message };
  }
}

async function postPdf(endpoint, params = {}) {
  try {
    const response = await axios.post(`${BASE_URL}${endpoint}`, {
      ...params,
      api_key: API_KEY,
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 30000,
      responseType: 'arraybuffer', // Important: get raw binary
    });

    return { success: true, data: Buffer.from(response.data), error: null };
  } catch (err) {
    return { success: false, data: null, error: err.message };
  }
}

module.exports = { post, postPdf };
```

### 3. Insurance Service (`services/insursOnlineService.js`)

```js
const client = require('./insursOnlineClient');

const PRODUCT_ID = 1;
const COMPANY_ID = 366;
const FRANCHISE_ID = 1;

// coverage_id mapping
const COVERAGE_MAP = {
  basic: 1,         // $35,000
  comprehensive: 2, // $100,000
  premium: 3,       // $500,000
};

async function calculatePrice({ dateFrom, dateTo, coverageTier, departureCountry, arrivalCountry, localityCoverage, touristDob, currency }) {
  const result = await client.post('/services/api/get_price', {
    product_id: PRODUCT_ID,
    company_id: COMPANY_ID,
    country_of_departure: departureCountry,
    country_of_arrive: arrivalCountry,
    locality_coverage: [localityCoverage || 208],
    additional_services: [0],
    params: {
      date_from: dateFrom,
      date_to: dateTo,
      coverage_id: COVERAGE_MAP[coverageTier] || 2,
      franchise_id: FRANCHISE_ID,
      type_of_travel: 1,
      currency: currency || 'USD',
      tourists: [{ date_birth: touristDob }],
    },
  });

  if (result.success && result.data.data?.length > 0) {
    const tariff = result.data.data[0];
    return {
      success: true,
      tariffId: tariff.tariff_id,
      tariffName: tariff.tariff_name,
      totalAmount: parseFloat(tariff.total_amount),
      currency: tariff.currency,
    };
  }

  return { success: false, error: result.error };
}

async function createContract({ tariffId, dateFrom, dateTo, coverageTier, departureCountry, arrivalCountry, localityCoverage, insurer, tourists, currency }) {
  const result = await client.post('/services/api/add_contract', {
    product_id: PRODUCT_ID,
    company_id: COMPANY_ID,
    tariff_id: tariffId,
    country_of_departure: departureCountry,
    country_of_arrive: arrivalCountry,
    locality_coverage: [localityCoverage || 208],
    insurer,
    tourists,
    params: {
      date_from: dateFrom,
      date_to: dateTo,
      coverage_id: COVERAGE_MAP[coverageTier] || 2,
      franchise_id: FRANCHISE_ID,
      currency: currency || 'USD',
    },
  });

  if (result.success && result.data.order_id) {
    return {
      success: true,
      orderId: result.data.order_id,
      policeNum: result.data.police_num,
      totalAmount: result.data.total_amount,
      currency: result.data.currency,
    };
  }

  return { success: false, error: result.error };
}

async function confirmContract(orderId) {
  const result = await client.post('/services/api/confirm_contract', {
    product_id: PRODUCT_ID,
    order_id: orderId,
    payment_id: -1,
  });

  return { success: result.success, error: result.error };
}

async function getPolicyPdf(orderId) {
  const result = await client.postPdf('/services/api/get_print_form', {
    product_id: PRODUCT_ID,
    order_id: orderId,
  });

  if (result.success && result.data) {
    return { success: true, pdfBuffer: result.data };
  }

  return { success: false, error: result.error };
}

async function cancelContract(orderId) {
  const result = await client.post('/services/api/cancel', {
    product_id: PRODUCT_ID,
    order_id: orderId,
  });

  return { success: result.success, error: result.error };
}

module.exports = {
  calculatePrice,
  createContract,
  confirmContract,
  getPolicyPdf,
  cancelContract,
};
```

### 4. Express Routes (`routes/insurance.js`)

```js
const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const insurance = require('../services/insursOnlineService');

// Step 1: Get a price quote
router.post('/quote', async (req, res) => {
  const { dateFrom, dateTo, coverageTier, departureCountry, arrivalCountry, touristDob } = req.body;

  const result = await insurance.calculatePrice({
    dateFrom,
    dateTo,
    coverageTier: coverageTier || 'comprehensive',
    departureCountry,
    arrivalCountry,
    localityCoverage: 208, // Schengen default
    touristDob,
    currency: 'USD',
  });

  if (result.success) {
    res.json({ success: true, quote: result });
  } else {
    res.status(422).json({ success: false, error: result.error });
  }
});

// Step 2: Create contract (call after collecting passport details, before payment)
router.post('/contract', async (req, res) => {
  const { tariffId, dateFrom, dateTo, coverageTier, departureCountry, arrivalCountry, insurer, tourists } = req.body;

  const result = await insurance.createContract({
    tariffId,
    dateFrom,
    dateTo,
    coverageTier,
    departureCountry,
    arrivalCountry,
    localityCoverage: 208,
    insurer,    // { first_name, last_name, phone, email, date_birth, passport }
    tourists,   // [{ first_name, last_name, date_birth, passport }]
    currency: 'USD',
  });

  if (result.success) {
    // Save orderId and policeNum to your database here
    res.json({ success: true, contract: result });
  } else {
    res.status(422).json({ success: false, error: result.error });
  }
});

// Step 3: Confirm contract (call after payment succeeds)
router.post('/confirm', async (req, res) => {
  const { orderId } = req.body;

  const result = await insurance.confirmContract(orderId);

  if (result.success) {
    res.json({ success: true, message: 'Contract confirmed' });
  } else {
    res.status(422).json({ success: false, error: result.error });
  }
});

// Step 4: Download policy PDF
router.get('/policy/:orderId', async (req, res) => {
  const { orderId } = req.params;

  const result = await insurance.getPolicyPdf(parseInt(orderId));

  if (result.success) {
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=policy_${orderId}.pdf`);
    res.send(result.pdfBuffer);
  } else {
    res.status(422).json({ success: false, error: result.error });
  }
});

module.exports = router;
```

### 5. App Entry Point (`app.js`)

```js
require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());
app.use('/api/insurance', require('./routes/insurance'));

app.listen(3000, () => console.log('Server running on port 3000'));
```

---

## Typical Integration Flow (Step by Step)

```
1. User fills form (dates, destination, coverage tier)
2. POST /api/insurance/quote
   -> Returns tariffId + price
   -> Show price to user

3. User enters passport details + clicks pay
4. POST /api/insurance/contract
   -> Creates contract at Insurs, returns orderId + policeNum
   -> Save these to your database

5. User completes payment (Stripe, etc.)
6. POST /api/insurance/confirm  (on payment webhook)
   -> Confirms the contract
   -> NOTE: police_num is NOT in this response, use the one from step 4

7. GET /api/insurance/policy/:orderId
   -> Downloads the PDF policy document
   -> Attach to email or serve to user
```

---

## Gotchas and Tips

1. **`locality_coverage` must be an array** — `[208]` not `208`. The API silently fails otherwise.

2. **`confirm_contract` does NOT return `police_num`** — Only `add_contract` does. Save it in step 2 and don't overwrite it in step 4.

3. **`cancel` endpoint may be unavailable** — As of Feb 2026 it returns "Method temporarily unavailable". Don't rely on it for critical cleanup flows.

4. **`payment_id` can be `-1`** — If you manage payments externally (e.g., Stripe), pass `-1` and the API accepts it.

5. **PDF is raw binary** — The `get_print_form` response body is the PDF file directly (~290KB), not base64 or JSON. Use `responseType: 'arraybuffer'` in axios.

6. **Dates format** — All dates must be `YYYY-MM-DD`.

7. **Country codes** — Use ISO 3166-1 alpha-2 (e.g., `DE`, `NG`, `US`, `FR`).

8. **Timeout** — Set at least 30 seconds. The pricing endpoint can be slow.

9. **Multiple tourists** — The `tourists` array supports multiple travelers. Each needs `date_birth` for pricing and full details for contracts.
