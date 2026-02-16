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
    <section id="contact" className="py-12 md:py-16 scroll-mt-14">
      <div className="mb-4">
        <h2 className="text-lg font-bold text-black">Contact</h2>
        <p className="text-sm text-[#9B9B9B]">Get in touch</p>
      </div>

      {success && (
        <div className="max-w-lg mb-8">
          <div className="p-4 rounded bg-[#DBEDDB] border border-[#4DAB9A]/30">
            <p className="text-sm font-medium text-black">
              Message sent successfully! We&apos;ll get back to you soon.
            </p>
          </div>
        </div>
      )}

      {!success && (
        <div className="max-w-lg">
          <form onSubmit={handleSubmit} className="space-y-5">
            {Object.keys(errors).length > 0 && (
              <div className="p-4 rounded bg-[#FBE4E4] border border-[#EB5757]/30">
                <p className="text-sm font-medium text-black mb-2">
                  Please fix the following:
                </p>
                <ul className="list-disc list-inside space-y-1">
                  {Object.entries(errors).map(([field, messages]) =>
                    (Array.isArray(messages) ? messages : [messages]).map((msg, i) => (
                      <li key={`${field}-${i}`} className="text-sm text-[#EB5757]">
                        {msg}
                      </li>
                    ))
                  )}
                </ul>
              </div>
            )}

            <div>
              <label
                htmlFor="name"
                className="block text-xs font-medium text-[#9B9B9B] uppercase tracking-wider mb-1.5"
              >
                Name
              </label>
              <input
                type="text"
                id="name"
                required
                placeholder="Jane Doe"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-3 py-2 text-base rounded border border-[#E3E2DE] bg-white text-black placeholder:text-[#C8C8C8] focus:outline-none focus:border-[#2383E2] focus:ring-1 focus:ring-[#2383E2] transition-colors"
              />
            </div>

            <div>
              <label
                htmlFor="email"
                className="block text-xs font-medium text-[#9B9B9B] uppercase tracking-wider mb-1.5"
              >
                Email
              </label>
              <input
                type="email"
                id="email"
                required
                placeholder="jane@example.com"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="w-full px-3 py-2 text-base rounded border border-[#E3E2DE] bg-white text-black placeholder:text-[#C8C8C8] focus:outline-none focus:border-[#2383E2] focus:ring-1 focus:ring-[#2383E2] transition-colors"
              />
            </div>

            <div>
              <label
                htmlFor="message"
                className="block text-xs font-medium text-[#9B9B9B] uppercase tracking-wider mb-1.5"
              >
                Message
              </label>
              <textarea
                id="message"
                required
                placeholder="Tell us about your idea, challenge, or question..."
                rows={5}
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                className="w-full px-3 py-2 text-base rounded border border-[#E3E2DE] bg-white text-black placeholder:text-[#C8C8C8] focus:outline-none focus:border-[#2383E2] focus:ring-1 focus:ring-[#2383E2] transition-colors resize-y"
              />
            </div>

            <div className="absolute -left-[9999px]" aria-hidden="true">
              <input
                type="text"
                name="website"
                tabIndex={-1}
                autoComplete="off"
                value={formData.website}
                onChange={(e) => setFormData({ ...formData, website: e.target.value })}
              />
            </div>

            <div>
              <button
                type="submit"
                disabled={submitting}
                className="px-4 py-2 text-sm font-medium text-white bg-black rounded hover:bg-[#333] transition-colors cursor-pointer disabled:opacity-50"
              >
                {submitting ? "Sending..." : "Send message"}
              </button>
            </div>
          </form>

          <div className="mt-6">
            <p className="text-base text-[#9B9B9B]">
              Or email us directly at{" "}
              <a href="mailto:hello@cr4fts.com" className="text-[#6B6B6B] hover:text-black hover:underline transition-colors">
                hello@cr4fts.com
              </a>
            </p>
          </div>
        </div>
      )}
    </section>
  )
}
