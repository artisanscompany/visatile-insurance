import Footer from "@/components/shared/Footer"
import FlashMessages from "@/components/shared/FlashMessages"
import ScrollIndicator from "@/components/shared/ScrollIndicator"

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex flex-col">
      <ScrollIndicator />
      <main className="flex-1 max-w-4xl mx-auto w-full px-6 md:px-12">
        <FlashMessages />
        {children}
      </main>
      <Footer />
    </div>
  )
}
