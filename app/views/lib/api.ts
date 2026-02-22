function getCsrfToken(): string {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
}

export async function apiPost<T = unknown>(url: string, data: object): Promise<T> {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getCsrfToken(),
      Accept: 'application/json',
    },
    body: JSON.stringify(data),
    credentials: 'same-origin',
  })

  const body = await response.json()

  if (!response.ok) {
    throw new Error(body.error || 'Request failed')
  }

  return body as T
}

export async function apiGet<T = unknown>(url: string): Promise<T> {
  const response = await fetch(url, {
    headers: { Accept: 'application/json' },
    credentials: 'same-origin',
  })

  const body = await response.json()

  if (!response.ok) {
    throw new Error(body.error || 'Request failed')
  }

  return body as T
}
