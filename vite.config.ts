import { defineConfig, type Plugin } from "vite"
import RubyPlugin from "vite-plugin-ruby"
import react from "@vitejs/plugin-react"
import tailwindcss from "@tailwindcss/vite"
import { resolve } from "path"

// Fix vite-plugin-ruby's config hook that uses `this.meta` incorrectly
function patchRubyPlugin(): Plugin[] {
  const plugins = RubyPlugin() as Plugin[]
  return plugins.map((plugin) => {
    if (plugin.name === "vite-plugin-ruby" && typeof plugin.config === "function") {
      const originalConfig = plugin.config
      plugin.config = function (this: any, config, env) {
        return originalConfig.call({ meta: {} }, config, env)
      }
    }
    return plugin
  })
}

export default defineConfig({
  plugins: [
    ...patchRubyPlugin(),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      "@": resolve(__dirname, "app/frontend"),
    },
  },
})
