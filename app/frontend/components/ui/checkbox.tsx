import * as React from "react"
import { cn } from "@/lib/utils"
import { Check } from "lucide-react"

interface CheckboxProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "type"> {
  onCheckedChange?: (checked: boolean) => void
}

const Checkbox = React.forwardRef<HTMLInputElement, CheckboxProps>(
  ({ className, onCheckedChange, ...props }, ref) => {
    return (
      <div className="relative inline-flex items-center">
        <input
          type="checkbox"
          className="peer sr-only"
          ref={ref}
          onChange={(e) => onCheckedChange?.(e.target.checked)}
          {...props}
        />
        <div
          className={cn(
            "h-4 w-4 rounded border border-[#E5E7EB] bg-white peer-checked:bg-[#17233C] peer-checked:border-[#17233C] peer-focus-visible:ring-2 peer-focus-visible:ring-[#17233C] peer-focus-visible:ring-offset-2 cursor-pointer flex items-center justify-center",
            className
          )}
          onClick={() => {
            const input = ref && "current" in ref ? ref.current : null
            if (input) {
              input.click()
            }
          }}
        >
          <Check className="h-3 w-3 text-white hidden peer-checked:block" />
        </div>
      </div>
    )
  }
)
Checkbox.displayName = "Checkbox"

export { Checkbox }
