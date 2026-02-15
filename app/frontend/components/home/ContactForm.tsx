import { useState } from "react"
import { router } from "@inertiajs/react"

export default function ContactForm() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    message: "",
    website: "",
  })
  const [errors, setErrors] = useState<Record<string, string[]>>({})
  const [submitting, setSubmitting] = useState(false)
  const [success, setSuccess] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (formData.website) return

    setSubmitting(true)
    setErrors({})

    router.post(
      "/contact",
      {
        contact: {
          name: formData.name,
          email: formData.email,
          message: formData.message,
        },
        website: formData.website,
      },
      {
        preserveScroll: true,
        onSuccess: () => {
          setSuccess(true)
          setFormData({ name: "", email: "", message: "", website: "" })
          setSubmitting(false)
        },
        onError: (errs) => {
          setErrors(errs as unknown as Record<string, string[]>)
          setSubmitting(false)
        },
      }
    )
  }

  return (
    <section id="contact" className="relative py-16 md:py-24 scroll-mt-20">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <div className="text-center mb-12 md:mb-16">
          <h2
            className="text-2xl md:text-3xl lg:text-4xl font-black leading-snug mb-2 md:mb-3"
            style={{ color: "#17233C", letterSpacing: "-0.02em", wordSpacing: "-0.05em" }}
          >
            Get in touch.
          </h2>
          <p
            className="text-xl md:text-2xl lg:text-3xl leading-relaxed font-light"
            style={{ color: "#17233C", opacity: 0.8 }}
          >
            We read everything and respond to what resonates.
          </p>
        </div>

        {/* Success Message */}
        {success && (
          <div className="max-w-2xl mx-auto mb-8">
            <div className="p-6 rounded-2xl border-2 border-green-200 bg-green-50">
              <h3 className="text-xl font-bold mb-2" style={{ color: "#17233C" }}>
                Message sent successfully!
              </h3>
              <p className="text-lg" style={{ color: "#17233C", opacity: 0.8 }}>
                Thanks for reaching out! We&apos;ll get back to you soon.
              </p>
            </div>
          </div>
        )}

        {/* Contact Form */}
        {!success && (
          <div className="max-w-2xl mx-auto">
            <div
              className="p-8 md:p-12 border transform rotate-1 relative"
              style={{ backgroundColor: "#FFFFFF", borderColor: "#E5E7EB" }}
            >
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Error Messages */}
                {Object.keys(errors).length > 0 && (
                  <div className="p-4 rounded-xl border-2 border-red-200 bg-red-50">
                    <h3 className="text-lg font-bold mb-2" style={{ color: "#17233C" }}>
                      Please fix the following errors:
                    </h3>
                    <ul className="list-disc list-inside space-y-1">
                      {Object.entries(errors).map(([field, messages]) =>
                        (Array.isArray(messages) ? messages : [messages]).map((msg, i) => (
                          <li key={`${field}-${i}`} className="text-sm text-red-600">
                            {msg}
                          </li>
                        ))
                      )}
                    </ul>
                  </div>
                )}

                {/* Name Field */}
                <div>
                  <label
                    htmlFor="name"
                    className="block text-sm font-bold mb-2 uppercase tracking-wider"
                    style={{ color: "#17233C" }}
                  >
                    Your Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    required
                    placeholder="Jane Doe"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-blue-400 focus:outline-none transition-colors"
                    style={{ color: "#17233C", backgroundColor: "#FAFAFA" }}
                  />
                </div>

                {/* Email Field */}
                <div>
                  <label
                    htmlFor="email"
                    className="block text-sm font-bold mb-2 uppercase tracking-wider"
                    style={{ color: "#17233C" }}
                  >
                    Email Address
                  </label>
                  <input
                    type="email"
                    id="email"
                    required
                    placeholder="jane@example.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-blue-400 focus:outline-none transition-colors"
                    style={{ color: "#17233C", backgroundColor: "#FAFAFA" }}
                  />
                </div>

                {/* Message Field */}
                <div>
                  <label
                    htmlFor="message"
                    className="block text-sm font-bold mb-2 uppercase tracking-wider"
                    style={{ color: "#17233C" }}
                  >
                    Message
                  </label>
                  <textarea
                    id="message"
                    required
                    placeholder="Tell us about your idea, challenge, or question..."
                    rows={6}
                    value={formData.message}
                    onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-blue-400 focus:outline-none transition-colors resize-y"
                    style={{ color: "#17233C", backgroundColor: "#FAFAFA" }}
                  />
                </div>

                {/* Honeypot */}
                <div style={{ position: "absolute", left: "-9999px" }} aria-hidden="true">
                  <input
                    type="text"
                    name="website"
                    tabIndex={-1}
                    autoComplete="off"
                    value={formData.website}
                    onChange={(e) => setFormData({ ...formData, website: e.target.value })}
                  />
                </div>

                {/* Submit Button */}
                <div className="pt-4">
                  <button
                    type="submit"
                    disabled={submitting}
                    className="w-full px-8 py-4 text-white text-lg font-bold rounded-xl hover:shadow-xl transition-all cursor-pointer disabled:opacity-50"
                    style={{ background: "#17233C" }}
                  >
                    {submitting ? "Sending your message..." : "Send Message"}
                  </button>
                </div>
              </form>
            </div>

            {/* Alternative Contact */}
            <div className="mt-8 text-center">
              <p className="text-lg" style={{ color: "#17233C", opacity: 0.8 }}>
                Or email us directly at{" "}
                <a href="mailto:hello@cr4fts.com" className="font-bold hover:underline" style={{ color: "#60A5FA" }}>
                  hello@cr4fts.com
                </a>
              </p>
            </div>
          </div>
        )}
      </div>
    </section>
  )
}
