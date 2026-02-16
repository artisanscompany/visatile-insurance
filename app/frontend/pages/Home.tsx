import Hero from "@/components/home/Hero"
import Manifesto from "@/components/home/Manifesto"
import Portfolio from "@/components/home/Portfolio"
import MakerspaceCallout from "@/components/home/MakerspaceCallout"
import FAQ from "@/components/home/FAQ"
import ContactForm from "@/components/home/ContactForm"
import type { Project, FaqItem } from "@/types"

interface HomeProps {
  projects: Project[]
  faqs: FaqItem[]
}

export default function Home({ projects, faqs }: HomeProps) {
  return (
    <>
      <Hero />
      <Manifesto />
      <Portfolio projects={projects} />
      <MakerspaceCallout />
      <FAQ faqs={faqs} />
      <ContactForm />
    </>
  )
}
