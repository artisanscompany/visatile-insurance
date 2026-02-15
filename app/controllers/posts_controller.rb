class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    render inertia: "posts/Index", props: {
      posts: Post.all.order(created_at: :desc).map { |post| serialize_post(post) }
    }
  end

  def show
    render inertia: "posts/Show", props: {
      post: serialize_post(@post)
    }
  end

  def new
    render inertia: "posts/New", props: {
      post: { title: "", body: "", published: false }
    }
  end

  def edit
    render inertia: "posts/Edit", props: {
      post: serialize_post(@post)
    }
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      redirect_back fallback_location: new_post_path, inertia: { errors: @post.errors.to_hash(true) }
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      redirect_back fallback_location: edit_post_path(@post), inertia: { errors: @post.errors.to_hash(true) }
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "Post was successfully destroyed."
  end

  def test_worker
    TestWorkerJob.perform_later("Test triggered at #{Time.current}")
    redirect_to posts_path, notice: "Worker test job enqueued! Check the worker logs."
  end

  private

  def set_post
    @post = Post.find(params.expect(:id))
  end

  def post_params
    params.expect(post: [ :title, :body, :published ])
  end

  def serialize_post(post)
    {
      id: post.id,
      title: post.title,
      body: post.body,
      published: post.published,
      created_at: post.created_at.iso8601,
      updated_at: post.updated_at.iso8601
    }
  end
end
