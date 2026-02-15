import { useForm } from "@inertiajs/react"
import { Button } from "@/components/ui/button"

interface PostFormProps {
  post: {
    id?: number
    title: string
    body: string
    published: boolean
  }
  submitUrl: string
  method: "post" | "put"
}

export default function PostForm({ post, submitUrl, method }: PostFormProps) {
  const { data, setData, processing, errors, submit } = useForm({
    title: post.title,
    body: post.body,
    published: post.published,
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    submit(method, submitUrl, {
      data: { post: data },
    })
  }

  return (
    <form onSubmit={handleSubmit} className="contents">
      {Object.keys(errors).length > 0 && (
        <div className="bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3">
          <ul className="list-disc ml-6">
            {Object.entries(errors).map(([field, message]) => (
              <li key={field}>{message}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="my-5">
        <label htmlFor="title" className="block font-medium mb-1">Title</label>
        <input
          id="title"
          type="text"
          value={data.title}
          onChange={(e) => setData("title", e.target.value)}
          className={`block shadow-sm rounded-md border px-3 py-2 mt-2 w-full ${
            errors.title ? "border-red-400 focus:outline-red-600" : "border-gray-400 focus:outline-blue-600"
          }`}
        />
      </div>

      <div className="my-5">
        <label htmlFor="body" className="block font-medium mb-1">Body</label>
        <textarea
          id="body"
          rows={4}
          value={data.body}
          onChange={(e) => setData("body", e.target.value)}
          className={`block shadow-sm rounded-md border px-3 py-2 mt-2 w-full ${
            errors.body ? "border-red-400 focus:outline-red-600" : "border-gray-400 focus:outline-blue-600"
          }`}
        />
      </div>

      <div className="my-5 flex items-center gap-2">
        <input
          id="published"
          type="checkbox"
          checked={data.published}
          onChange={(e) => setData("published", e.target.checked)}
          className={`block shadow-sm rounded-md border h-5 w-5 ${
            errors.published ? "border-red-400 focus:outline-red-600" : "border-gray-400 focus:outline-blue-600"
          }`}
        />
        <label htmlFor="published" className="font-medium">Published</label>
      </div>

      <div className="inline">
        <Button type="submit" disabled={processing} className="bg-blue-600 hover:bg-blue-500">
          {processing ? "Saving..." : post.id ? "Update Post" : "Create Post"}
        </Button>
      </div>
    </form>
  )
}
