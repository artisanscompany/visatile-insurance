interface VentureCardProps {
  id: string
  title: string
  subtitle: string
  image: string
  featured?: boolean
  onOpen: (id: string) => void
}

export default function VentureCard({ id, title, subtitle, image, featured, onOpen }: VentureCardProps) {
  return (
    <button
      type="button"
      onClick={() => onOpen(id)}
      className="block w-full pb-[100%] relative group overflow-hidden rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-500 venture-card border-4 border-white"
    >
      <div className="absolute inset-0">
        <img src={image} alt={title} className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
      </div>
      <div className="absolute inset-0 bg-gradient-to-br from-black/40 via-black/30 to-transparent group-hover:from-black/60 group-hover:via-black/40 transition-all duration-500" />
      <div className="absolute inset-0 flex flex-col justify-end items-start p-5 md:p-6">
        <div className="transform transition-transform duration-500 group-hover:translate-y-0 translate-y-2">
          <h3
            className={`font-black text-white mb-1 leading-tight text-left ${
              featured ? "text-3xl md:text-4xl lg:text-5xl mb-2" : "text-xl md:text-2xl"
            }`}
          >
            {title}
          </h3>
          <p className={`text-white/80 font-medium text-left ${featured ? "text-sm md:text-base" : "text-xs md:text-sm text-white/70"}`}>
            {subtitle}
          </p>
        </div>
      </div>
    </button>
  )
}
