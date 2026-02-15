import { useInView } from "@/hooks/useInView"

interface FadeInProps {
  children: React.ReactNode
  className?: string
  delay?: number
}

export default function FadeIn({ children, className = "", delay = 0 }: FadeInProps) {
  const { ref, inView } = useInView(0.1)

  return (
    <div
      ref={ref}
      className={className}
      style={{
        opacity: inView ? 1 : 0,
        transform: inView ? "translateY(0)" : "translateY(20px)",
        transition: `opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms, transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms`,
      }}
    >
      {children}
    </div>
  )
}
