import { Link } from "@inertiajs/react"
import PostForm from "@/components/posts/PostForm"
import type { Post } from "@/types"

export default function PostsEdit({ post }: { post: Post }) {
  return (
    <div className="md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Editing post</h1>

      <PostForm post={post} submitUrl={`/posts/${post.id}`} method="put" />

      <Link
        href={`/posts/${post.id}`}
        className="mt-5 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      >
        Show this post
      </Link>
      <Link
        href="/posts"
        className="mt-5 ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      >
        Back to posts
      </Link>
    </div>
  )
}
