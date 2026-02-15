import { Link, router } from "@inertiajs/react"
import type { Post } from "@/types"

export default function PostsShow({ post }: { post: Post }) {
  const handleDestroy = () => {
    if (confirm("Are you sure?")) {
      router.delete(`/posts/${post.id}`)
    }
  }

  return (
    <div className="md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Showing post</h1>

      <div className="w-full sm:w-auto my-5 space-y-5">
        <div>
          <strong className="block font-medium mb-1">Title:</strong>
          {post.title}
        </div>
        <div>
          <strong className="block font-medium mb-1">Body:</strong>
          {post.body}
        </div>
        <div>
          <strong className="block font-medium mb-1">Published:</strong>
          {post.published ? "Yes" : "No"}
        </div>
      </div>

      <Link
        href={`/posts/${post.id}/edit`}
        className="w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      >
        Edit this post
      </Link>
      <Link
        href="/posts"
        className="w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      >
        Back to posts
      </Link>
      <button
        onClick={handleDestroy}
        className="w-full sm:w-auto mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer"
      >
        Destroy this post
      </button>
    </div>
  )
}
