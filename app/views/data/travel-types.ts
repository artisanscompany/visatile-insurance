export type TravelType = {
  id: number
  label: string
  description: string
}

export const TRAVEL_TYPES: TravelType[] = [
  { id: 1, label: "Calm", description: "Standard leisure travel" },
  { id: 2, label: "Active", description: "Hiking, skiing, sports" },
  { id: 3, label: "Extreme", description: "Extreme sports, hazardous" },
  { id: 4, label: "Pro Sport", description: "Professional athletics" },
  { id: 34, label: "Student", description: "Study abroad, exchange" },
  { id: 35, label: "Work", description: "Business travel" },
  { id: 36, label: "Cruise", description: "Cruise ship travel" },
]

export const TRAVEL_TYPE_MAP: Record<number, string> = Object.fromEntries(
  TRAVEL_TYPES.map(t => [t.id, t.label])
)
