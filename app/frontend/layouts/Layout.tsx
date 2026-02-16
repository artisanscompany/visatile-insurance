import Footer from "@/components/shared/Footer"
import FlashMessages from "@/components/shared/FlashMessages"

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex flex-col">
      <main className="flex-1 max-w-4xl mx-auto w-full px-6 md:px-12">
        <FlashMessages />
        {children}
      </main>
      <Footer />
    </div>
  )
}
