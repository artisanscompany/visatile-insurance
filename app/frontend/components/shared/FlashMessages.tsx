import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types"

export default function FlashMessages() {
  const { flash } = usePage<{ props: SharedProps }>().props as unknown as SharedProps

  if (!flash.notice && !flash.alert) return null

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-4">
      {flash.notice && (
        <div className="p-4 rounded-2xl border-2 border-green-200 bg-green-50 mb-4">
          <p className="text-lg font-medium" style={{ color: "#17233C" }}>
            {flash.notice}
          </p>
        </div>
      )}
      {flash.alert && (
        <div className="p-4 rounded-2xl border-2 border-red-200 bg-red-50 mb-4">
          <p className="text-lg font-medium" style={{ color: "#17233C" }}>
            {flash.alert}
          </p>
        </div>
      )}
    </div>
  )
}
