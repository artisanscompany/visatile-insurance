import { createInertiaApp } from "@inertiajs/react"
import { createRoot } from "react-dom/client"
import Layout from "@/layouts/Layout"
import "@/styles/application.css"

createInertiaApp({
  resolve: (name) => {
    const pages = import.meta.glob("../pages/**/*.tsx", { eager: true }) as Record<
      string,
      { default: React.ComponentType<any> }
    >
    const page = pages[`../pages/${name}.tsx`]
    if (!page) throw new Error(`Page not found: ${name}`)
    const component = page.default
    if (!component.layout) {
      component.layout = (page: React.ReactNode) => <Layout>{page}</Layout>
    }
    return component
  },
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
