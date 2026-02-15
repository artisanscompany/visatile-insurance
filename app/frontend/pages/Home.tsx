import Hero from "@/components/home/Hero"
import Manifesto from "@/components/home/Manifesto"
import Portfolio from "@/components/home/Portfolio"
import MakerspaceCallout from "@/components/home/MakerspaceCallout"
import FAQ from "@/components/home/FAQ"
import ContactForm from "@/components/home/ContactForm"

export default function Home() {
  return (
    <>
      <Hero />
      <Manifesto />
      <Portfolio />
      <MakerspaceCallout />
      <FAQ />
      <ContactForm />
    </>
  )
}
