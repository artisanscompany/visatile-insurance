export interface Flash {
  notice?: string
  alert?: string
}

export interface SharedProps {
  flash: Flash
  currentYear: number
}

export interface Post {
  id: number
  title: string
  body: string
  published: boolean
  created_at: string
  updated_at: string
}

export interface Venture {
  id: string
  title: string
  description: string
  image: string
  url?: string
  status: "active" | "stealth"
  tags?: string[]
}

export interface Project {
  id: string
  name: string
  category: string | null
  description: string | null
  url: string | null
  image: string | null
}

export interface FaqItem {
  id: string
  question: string
  answer: string
}

export interface ContactErrors {
  name?: string[]
  email?: string[]
  message?: string[]
}
