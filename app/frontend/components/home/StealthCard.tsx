interface StealthCardProps {
  title: string
  image: string
  small?: boolean
  featured?: boolean
}

export default function StealthCard({ title, image, small, featured }: StealthCardProps) {
  return (
    <div className="block w-full pb-[100%] relative group overflow-hidden rounded-2xl">
      <div className="absolute inset-0">
        <img src={image} alt={title} className="w-full h-full object-cover grayscale transition-all duration-300 group-hover:grayscale-0" />
      </div>
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />
      <div className={`absolute inset-0 flex flex-col justify-end items-start ${small ? "p-4" : "p-5 md:p-6"}`}>
        <h3
          className={`font-semibold text-white leading-tight text-left ${
            featured
              ? "text-2xl md:text-3xl lg:text-4xl"
              : small
                ? "text-sm md:text-base"
                : "text-lg md:text-xl"
          }`}
        >
          {title}
        </h3>
      </div>
    </div>
  )
}
