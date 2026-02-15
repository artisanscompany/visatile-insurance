import Header from "@/components/shared/Header"
import Footer from "@/components/shared/Footer"
import FlashMessages from "@/components/shared/FlashMessages"

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex flex-col overflow-x-hidden">
      <Header />
      <main className="flex-1 max-w-4xl mx-auto w-full">
        <FlashMessages />
        {children}
      </main>
      <Footer />
    </div>
  )
}
