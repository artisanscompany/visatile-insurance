import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types"

export default function FlashMessages() {
  const { flash } = usePage<{ props: SharedProps }>().props as unknown as SharedProps

  if (!flash.notice && !flash.alert) return null

  return (
    <div className="pt-4">
      {flash.notice && (
        <div className="p-3 rounded bg-[#DBEDDB] border border-[#4DAB9A]/30 mb-4">
          <p className="text-sm text-black">{flash.notice}</p>
        </div>
      )}
      {flash.alert && (
        <div className="p-3 rounded bg-[#FBE4E4] border border-[#EB5757]/30 mb-4">
          <p className="text-sm text-black">{flash.alert}</p>
        </div>
      )}
    </div>
  )
}
