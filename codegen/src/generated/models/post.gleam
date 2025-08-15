import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{type Date, type TimeOfDay}
import gleam/time/timestamp.{type Timestamp}
import gleam/dynamic.{type Dynamic}

pub type Post {
  Post(
    id: String,
    title: String,
    content: Option(String),
    published: Bool,
    user_id: String,
    created_at: Int,
    updated_at: Int,
  )
}

pub type PostField {
  Id
  Title
  Content
  Published
  UserId
  CreatedAt
  UpdatedAt
}

/// Insert DTO for post (excludes auto-generated fields)
pub type InsertPost {
  InsertPost(
    title: String,
    content: Option(String),
    published: Bool,
    user_id: String,
  )
}

/// Partial Post for updates
pub type PartialPost {
  PartialPost(
  title: Option(String),
  content: Option(Option(String)),
  published: Option(Bool),
  user_id: Option(String)
  )
}

/// Create empty partial post for updates
pub fn empty_partial_post() -> PartialPost {
  PartialPost(title: None, content: None, published: None, user_id: None)
}

/// Create partial post from existing post
pub fn from_post(post: Post) -> PartialPost {
  PartialPost(
    title: Some(post.title),
    content: Some(post.content),
    published: Some(post.published),
    user_id: Some(post.user_id)
  )
}

/// Set title in partial post
pub fn with_title(partial: PartialPost, title: String) -> PartialPost {
  PartialPost(..partial, title: Some(title))
}

/// Set content in partial post
pub fn with_content(partial: PartialPost, content: Option(String)) -> PartialPost {
  PartialPost(..partial, content: Some(content))
}

/// Set published in partial post
pub fn with_published(partial: PartialPost, published: Bool) -> PartialPost {
  PartialPost(..partial, published: Some(published))
}

/// Set user_id in partial post
pub fn with_user_id(partial: PartialPost, user_id: String) -> PartialPost {
  PartialPost(..partial, user_id: Some(user_id))
}