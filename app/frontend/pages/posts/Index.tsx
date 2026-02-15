import { Link, router } from "@inertiajs/react"
import type { Post } from "@/types"

export default function PostsIndex({ posts }: { posts: Post[] }) {
  const handleDestroy = (id: number) => {
    if (confirm("Are you sure?")) {
      router.delete(`/posts/${id}`)
    }
  }

  const handleTestWorker = () => {
    router.post("/posts/test_worker")
  }

  return (
    <div className="w-full">
      <div className="flex justify-between items-center">
        <h1 className="font-bold text-4xl">Posts</h1>
        <div className="flex gap-2">
          <button
            onClick={handleTestWorker}
            className="rounded-md px-3.5 py-2.5 bg-yellow-600 hover:bg-yellow-500 text-white font-medium"
          >
            Test Worker
          </button>
          <Link
            href="/posts/new"
            className="rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium"
          >
            New post
          </Link>
        </div>
      </div>

      <div className="min-w-full divide-y divide-gray-200 space-y-5">
        {posts.length > 0 ? (
          posts.map((post) => (
            <div key={post.id} className="flex flex-col sm:flex-row justify-between items-center pb-5 sm:pb-0">
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
              <div className="w-full sm:w-auto flex flex-col sm:flex-row space-x-2 space-y-2">
                <Link
                  href={`/posts/${post.id}`}
                  className="w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
                >
                  Show
                </Link>
                <Link
                  href={`/posts/${post.id}/edit`}
                  className="w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
                >
                  Edit
                </Link>
                <button
                  onClick={() => handleDestroy(post.id)}
                  className="w-full sm:w-auto rounded-md px-3.5 py-2.5 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer"
                >
                  Destroy
                </button>
              </div>
            </div>
          ))
        ) : (
          <p className="text-center my-10">No posts found.</p>
        )}
      </div>
    </div>
  )
}
