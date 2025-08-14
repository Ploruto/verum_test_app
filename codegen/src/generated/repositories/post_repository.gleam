import generated/models/post.{type Post, type PartialPost}
import generated/queries/post_query
import generated/serializers/post_serializer
import pog.{type Connection, type QueryError}
import gleam/result
import gleam/list

/// Create a new post using type-safe parameters
pub fn create_post(conn: Connection, post: Post) -> Result(Post, QueryError) {
  let params = post_serializer.post_to_create_params(post)
  case params {
    [id_param, title_param, content_param, published_param, user_id_param] -> 
      post_query.create(conn, id_param, title_param, content_param, published_param, user_id_param)
    _ -> Error(pog.ConstraintViolated("Invalid parameters for Post", "", ""))
  }
}

/// Update post using partial data
pub fn update_post_partial(
  conn: Connection, 
  id: String, 
  partial: PartialPost
) -> Result(Post, QueryError) {
  let updates = post_serializer.partial_post_to_update_params(partial)
  case updates {
    [] -> 
      // No updates, just return existing record
      post_query.find_by_id(conn, pog.text(id)) 
      |> result.try(fn(results) {
        case results {
          [record] -> Ok(record)
          [] -> Error(pog.ConstraintViolated("Post not found", "", ""))
          _ -> Error(pog.ConstraintViolated("Multiple posts found", "", ""))
        }
      })
    _ -> post_query.update_partial(conn, pog.text(id), updates)
  }
}

/// Find post by primary key, returning single result or error
pub fn find_post_by_id(
  conn: Connection, 
  id: String
) -> Result(Post, QueryError) {
  post_query.find_by_id(conn, pog.text(id))
  |> result.try(fn(results) {
    case results {
      [record] -> Ok(record)
      [] -> Error(pog.ConstraintViolated("Post not found", "", ""))
      _ -> Error(pog.ConstraintViolated("Multiple posts found with same id", "", ""))
    }
  })
}

// Re-export common query operations for convenience
pub fn find_all_posts(conn: Connection) -> Result(List(Post), QueryError) {
  post_query.find_all(conn)
}

pub fn delete_post(conn: Connection, id: String) -> Result(Int, QueryError) {
  post_query.delete(conn, pog.text(id))
}