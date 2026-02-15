import { Link } from "@inertiajs/react"
import PostForm from "@/components/posts/PostForm"

export default function PostsNew({ post }: { post: { title: string; body: string; published: boolean } }) {
  return (
    <div className="md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">New post</h1>

      <PostForm post={post} submitUrl="/posts" method="post" />

      <Link
        href="/posts"
        className="mt-5 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      >
        Back to posts
      </Link>
    </div>
  )
}
