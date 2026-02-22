import type { ReactNode } from 'react'
import { Shield, X } from 'lucide-react'
import {
  Sheet,
  SheetContent,
  SheetTitle,
} from '@/components/ui/sheet'

type SlidePanelProps = {
  open: boolean
  onClose: () => void
  title: string
  children: ReactNode
  stepIndicator?: ReactNode
}

export function SlidePanel({ open, onClose, title, children, stepIndicator }: SlidePanelProps) {
  return (
    <Sheet open={open} onOpenChange={open => { if (!open) onClose() }}>
      <SheetContent
        side="right"
        showCloseButton={false}
        className="w-full sm:max-w-xl p-0 flex flex-col gap-0 border-l border-black/10"
      >
        {/* Panel header */}
        <div className="bg-black px-5 py-4 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 bg-yellow-400 rounded-lg flex items-center justify-center">
              <Shield className="w-3.5 h-3.5 text-black" />
            </div>
            <SheetTitle className="text-white text-sm font-bold tracking-tight">
              {title}
            </SheetTitle>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-lg flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Step indicator */}
        {stepIndicator && (
          <div className="px-5 py-3 border-b border-gray-200 bg-white shrink-0">
            {stepIndicator}
          </div>
        )}

        {/* Scrollable body */}
        <div className="flex-1 overflow-y-auto bg-[#fafaf8] p-5">
          {children}
        </div>
      </SheetContent>
    </Sheet>
  )
}
