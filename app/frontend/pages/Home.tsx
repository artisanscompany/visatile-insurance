import FadeIn from "@/components/home/FadeIn"
import Hero from "@/components/home/Hero"
import Manifesto from "@/components/home/Manifesto"
import Portfolio from "@/components/home/Portfolio"
import MakerspaceCallout from "@/components/home/MakerspaceCallout"
import FAQ from "@/components/home/FAQ"
import Team from "@/components/home/Team"
import ContactForm from "@/components/home/ContactForm"
import type { Project, FaqItem } from "@/types"

interface HomeProps {
  projects: Project[]
  faqs: FaqItem[]
}

export default function Home({ projects, faqs }: HomeProps) {
  return (
    <>
      <FadeIn>
        <Hero />
      </FadeIn>
      <FadeIn>
        <Manifesto />
      </FadeIn>
      <FadeIn>
        <Portfolio projects={projects} />
      </FadeIn>
      <FadeIn>
        <MakerspaceCallout />
      </FadeIn>
      <FadeIn>
        <FAQ faqs={faqs} />
      </FadeIn>
      <FadeIn>
        <Team />
      </FadeIn>
      <FadeIn>
        <ContactForm />
      </FadeIn>
    </>
  )
}
