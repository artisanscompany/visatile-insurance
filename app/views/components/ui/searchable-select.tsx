import * as React from "react"
import { ChevronDown, Check } from "lucide-react"
import { Popover, PopoverTrigger, PopoverContent } from "@/components/ui/popover"
import { cn } from "@/lib/utils"

export type SearchableSelectOption = {
  value: string
  label: string
}

interface SearchableSelectProps {
  value: string
  onValueChange: (value: string) => void
  options: SearchableSelectOption[]
  placeholder?: string
  searchPlaceholder?: string
  className?: string
}

export function SearchableSelect({
  value,
  onValueChange,
  options,
  placeholder = "Select an option...",
  searchPlaceholder = "Search...",
  className,
}: SearchableSelectProps) {
  const [open, setOpen] = React.useState(false)
  const [search, setSearch] = React.useState("")
  const [highlightedIndex, setHighlightedIndex] = React.useState(0)
  const searchInputRef = React.useRef<HTMLInputElement>(null)
  const listRef = React.useRef<HTMLDivElement>(null)

  const selectedLabel = React.useMemo(
    () => options.find((o) => o.value === value)?.label,
    [options, value]
  )

  const filtered = React.useMemo(() => {
    if (!search) return options
    const lower = search.toLowerCase()
    return options.filter((o) => o.label.toLowerCase().includes(lower))
  }, [options, search])

  // Reset highlighted index when filtered list changes
  React.useEffect(() => {
    setHighlightedIndex(0)
  }, [filtered])

  // Clear search when popover closes
  React.useEffect(() => {
    if (!open) {
      setSearch("")
      setHighlightedIndex(0)
    }
  }, [open])

  // Auto-focus search input when popover opens
  React.useEffect(() => {
    if (open) {
      // Small delay to allow popover to render
      const timer = setTimeout(() => {
        searchInputRef.current?.focus()
      }, 0)
      return () => clearTimeout(timer)
    }
  }, [open])

  // Scroll highlighted item into view
  React.useEffect(() => {
    if (!open) return
    const list = listRef.current
    if (!list) return
    const item = list.children[highlightedIndex] as HTMLElement | undefined
    if (item) {
      item.scrollIntoView({ block: "nearest" })
    }
  }, [highlightedIndex, open])

  const selectOption = React.useCallback(
    (optionValue: string) => {
      onValueChange(optionValue)
      setOpen(false)
    },
    [onValueChange]
  )

  const handleKeyDown = React.useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case "ArrowDown": {
          e.preventDefault()
          setHighlightedIndex((prev) =>
            prev < filtered.length - 1 ? prev + 1 : 0
          )
          break
        }
        case "ArrowUp": {
          e.preventDefault()
          setHighlightedIndex((prev) =>
            prev > 0 ? prev - 1 : filtered.length - 1
          )
          break
        }
        case "Enter": {
          e.preventDefault()
          const item = filtered[highlightedIndex]
          if (item) {
            selectOption(item.value)
          }
          break
        }
        case "Escape": {
          e.preventDefault()
          setOpen(false)
          break
        }
      }
    },
    [filtered, highlightedIndex, selectOption]
  )

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <button
          type="button"
          role="combobox"
          aria-expanded={open}
          className={cn(
            "flex h-10 w-full items-center justify-between px-3 border border-gray-200 rounded-xl bg-white text-sm transition-colors",
            "focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500",
            "disabled:cursor-not-allowed disabled:opacity-50",
            !value && "text-muted-foreground",
            className
          )}
        >
          <span className="truncate">
            {selectedLabel ?? placeholder}
          </span>
          <ChevronDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </button>
      </PopoverTrigger>
      <PopoverContent
        className="w-[--radix-popover-trigger-width] p-0"
        align="start"
      >
        <div className="flex flex-col" onKeyDown={handleKeyDown}>
          {/* Search input */}
          <div className="border-b border-gray-100 p-2">
            <input
              ref={searchInputRef}
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder={searchPlaceholder}
              className={cn(
                "flex h-9 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm",
                "placeholder:text-muted-foreground",
                "focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
              )}
            />
          </div>

          {/* Options list */}
          <div
            ref={listRef}
            role="listbox"
            className="max-h-[300px] overflow-y-auto p-1"
          >
            {filtered.length === 0 ? (
              <div className="px-3 py-6 text-center text-sm text-muted-foreground">
                No results found.
              </div>
            ) : (
              filtered.map((option, index) => {
                const isSelected = option.value === value
                const isHighlighted = index === highlightedIndex
                return (
                  <div
                    key={option.value}
                    role="option"
                    aria-selected={isSelected}
                    className={cn(
                      "relative flex cursor-pointer items-center rounded-lg px-3 py-2 text-sm outline-none select-none",
                      isHighlighted && "bg-gray-50",
                      isSelected && "bg-yellow-50 text-black font-medium",
                      !isSelected && !isHighlighted && "hover:bg-gray-50"
                    )}
                    onClick={() => selectOption(option.value)}
                    onMouseEnter={() => setHighlightedIndex(index)}
                  >
                    <span className="flex-1 truncate">{option.label}</span>
                    {isSelected && (
                      <Check className="ml-2 h-4 w-4 shrink-0 text-yellow-600" />
                    )}
                  </div>
                )
              })
            )}
          </div>
        </div>
      </PopoverContent>
    </Popover>
  )
}
