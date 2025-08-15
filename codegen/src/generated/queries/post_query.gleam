import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import generated/models/post.{type Post, type PostField, Post, Id, Title, Content, Published, UserId, CreatedAt, UpdatedAt}
import pog.{type Connection, type QueryError, type Returned, type Value}

/// Timestamp decoder - decode integers to strings for now  
const decode_timestamp = decode.int

/// Decoder for converting database rows to Post type
/// Expects columns in order: id, title, content, published, user_id, created_at, updated_at
fn post_decoder() {
  {
    use id <- decode.field(0, decode.string)
  use title <- decode.field(1, decode.string)
  use content <- decode.field(2, decode.optional(decode.string))
  use published <- decode.field(3, decode.bool)
  use user_id <- decode.field(4, decode.string)
  use created_at <- decode.field(5, decode_timestamp)
  use updated_at <- decode.field(6, decode_timestamp)
    decode.success(Post(id:, title:, content:, published:, user_id:, created_at:, updated_at:))
  }
}

/// Convert PostField to database column name
pub fn field_to_column_name(field: PostField) -> String {
  case field {
    Id -> "id"
    Title -> "title"
    Content -> "content"
    Published -> "published"
    UserId -> "user_id"
    CreatedAt -> "created_at"
    UpdatedAt -> "updated_at"
  }
}

/// Find all post records
pub fn find_all(conn: Connection) -> Result(List(Post), QueryError) {
  let query = 
    pog.query("SELECT id, title, content, published, user_id, created_at, updated_at FROM posts")
    |> pog.returning(post_decoder())
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Find post records by a specific field
pub fn find_by_field(
  conn: Connection,
  field: PostField,
  value: Value,
) -> Result(List(Post), QueryError) {
  let field_name = field_to_column_name(field)
  let sql = "SELECT id, title, content, published, user_id, created_at, updated_at FROM posts WHERE " <> field_name <> " = $1"
  
  let query = 
    pog.query(sql)
    |> pog.returning(post_decoder())
    |> pog.parameter(value)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Find a post by ID
pub fn find_by_id(conn: Connection, id: Value) -> Result(List(Post), QueryError) {
  let query = 
    pog.query("SELECT id, title, content, published, user_id, created_at, updated_at FROM posts WHERE id = $1")
    |> pog.returning(post_decoder())
    |> pog.parameter(id)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Create a new post record
pub fn create(
  conn: Connection,
  title: Value,
  content: Value,
  published: Value,
  user_id: Value,
) -> Result(Post, QueryError) {
  let sql = "INSERT INTO posts (title, content, published, user_id) VALUES ($1, $2, $3, $4) RETURNING id, title, content, published, user_id, created_at, updated_at"
  
  let query = 
    pog.query(sql)
    |> pog.returning(post_decoder())
    |> pog.parameter(title)
    |> pog.parameter(content)
    |> pog.parameter(published)
    |> pog.parameter(user_id)
  
  case pog.execute(query, conn) {
    Ok(result) -> {
      case result.rows {
        [user] -> Ok(user)
        _ -> Error(pog.ConstraintViolated("Expected exactly one Post", "", ""))
      }
    }
    Error(error) -> Error(error)
  }
}

/// Update a post record by ID
pub fn update(
  conn: Connection,
  id: Value,
  title: Value,
  content: Value,
  published: Value,
  user_id: Value,
) -> Result(Post, QueryError) {
  let sql = "UPDATE posts SET title = $2, content = $3, published = $4, user_id = $5 WHERE id = $1 RETURNING id, title, content, published, user_id, created_at, updated_at"
  
  let query = 
    pog.query(sql)
    |> pog.returning(post_decoder())
    |> pog.parameter(id)
    |> pog.parameter(title)
    |> pog.parameter(content)
    |> pog.parameter(published)
    |> pog.parameter(user_id)
  
  case pog.execute(query, conn) {
    Ok(result) -> {
      case result.rows {
        [user] -> Ok(user)
        _ -> Error(pog.ConstraintViolated("Expected exactly one Post", "", ""))
      }
    }
    Error(error) -> Error(error)
  }
}

/// Update post record with dynamic field updates
pub fn update_partial(
  conn: Connection,
  id: Value,
  updates: List(#(String, Value)),
) -> Result(Post, QueryError) {
  case updates {
    [] -> Error(pog.ConstraintViolated("No fields to update", "", ""))
    _ -> {
      let set_clauses =
        updates
        |> list.index_map(fn(update, i) {
          let #(field_name, _) = update
          field_name <> " = $" <> int.to_string(i + 2)
        })
        |> string.join(", ")
      
      let sql = "UPDATE posts SET " <> set_clauses <> " WHERE id = $1 RETURNING id, title, content, published, user_id, created_at, updated_at"
      
      let query =
        pog.query(sql)
        |> pog.returning(post_decoder())
        |> pog.parameter(id)
      
      let final_query =
        updates
        |> list.fold(query, fn(q, update) {
          let #(_, value) = update
          pog.parameter(q, value)
        })
      
      case pog.execute(final_query, conn) {
        Ok(result) -> {
          case result.rows {
            [record] -> Ok(record)
            [] -> Error(pog.ConstraintViolated("Post not found", "", ""))
            _ -> Error(pog.ConstraintViolated("Multiple posts updated", "", ""))
          }
        }
        Error(error) -> Error(error)
      }
    }
  }
}

/// Delete a post record by ID
pub fn delete(conn: Connection, id: Value) -> Result(Int, QueryError) {
  let query = 
    pog.query("DELETE FROM posts WHERE id = $1")
    |> pog.returning(decode.dynamic)
    |> pog.parameter(id)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.count)
    Error(error) -> Error(error)
  }
}