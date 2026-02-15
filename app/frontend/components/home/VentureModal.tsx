import { Dialog } from "@/components/ui/dialog"
import { ArrowRight } from "lucide-react"

interface VentureModalProps {
  open: boolean
  onClose: () => void
  title: string
  description: string
  image: string
}

export default function VentureModal({ open, onClose, title, description, image }: VentureModalProps) {
  return (
    <Dialog open={open} onClose={onClose}>
      <div className="relative w-full max-w-3xl mx-auto">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute -top-8 md:-top-12 right-0 text-white hover:text-white/70 transition-colors z-10"
        >
          <svg className="w-8 h-8 md:w-10 md:h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        {/* Modal Content */}
        <div className="bg-white rounded-2xl md:rounded-3xl overflow-hidden shadow-2xl">
          <div className="relative aspect-square">
            <img src={image} alt={title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-br from-black/40 via-black/20 to-transparent" />
            <div className="absolute inset-0 flex flex-col justify-end p-4 sm:p-6 md:p-8 lg:p-12">
              <div className="bg-white/90 backdrop-blur-sm rounded-xl md:rounded-2xl p-4 sm:p-5 md:p-6 lg:p-8">
                <h2
                  className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-black mb-2 sm:mb-3 md:mb-4 leading-tight"
                  style={{ color: "#17233C" }}
                >
                  {title}
                </h2>
                <p
                  className="text-sm sm:text-base md:text-lg lg:text-xl font-medium mb-4 sm:mb-5 md:mb-6"
                  style={{ color: "#17233C", opacity: 0.8 }}
                >
                  {description}
                </p>
                <a
                  href="#"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 md:gap-3 px-6 py-3 md:px-8 md:py-4 text-white text-base md:text-lg font-bold rounded-lg md:rounded-xl hover:shadow-xl transition-all group self-start"
                  style={{ background: "#17233C" }}
                >
                  View
                  <ArrowRight className="w-4 h-4 md:w-5 md:h-5 group-hover:translate-x-1 transition-transform" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Dialog>
  )
}
