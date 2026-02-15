import { Plus } from "lucide-react"

export default function EmptySlotCard() {
  return (
    <div className="block w-full pb-[100%] relative overflow-hidden rounded-2xl border border-dashed border-border bg-muted/30">
      <div className="absolute inset-0 flex flex-col items-center justify-center p-4">
        <Plus className="w-5 h-5 text-muted-foreground/50 mb-1" />
        <p className="text-xs text-muted-foreground/50">
          Coming soon
        </p>
      </div>
    </div>
  )
}
