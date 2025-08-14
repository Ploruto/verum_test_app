import generated/models/post.{type Post, type PartialPost}
import pog.{type Value}
import gleam/option.{None, Some}
import gleam/list

/// Convert Post to create parameters
pub fn post_to_create_params(post: Post) -> List(Value) {
  [
    pog.text(post.id),
    pog.text(post.title),
    case post.content {
      Some(val) -> pog.text(val)
      None -> pog.null()
    },
    pog.bool(post.published),
    pog.text(post.user_id)
  ]
}

/// Convert PartialPost to update parameters
pub fn partial_post_to_update_params(partial: PartialPost) -> List(#(String, Value)) {
  []
  |> add_if_present("title", partial.title, pog.text)
  |> add_if_present_optional("content", partial.content, pog.text, pog.null())
  |> add_if_present("published", partial.published, pog.bool)
  |> add_if_present("user_id", partial.user_id, pog.text)
}

/// Add field to update list if value is present
fn add_if_present(
  acc: List(#(String, Value)),
  field: String,
  value: option.Option(a),
  converter: fn(a) -> Value,
) -> List(#(String, Value)) {
  case value {
    Some(v) -> [#(field, converter(v)), ..acc]
    None -> acc
  }
}

/// Add optional field to update list if value is present (handles triple Option for nulls)
fn add_if_present_optional(
  acc: List(#(String, Value)),
  field: String,
  value: option.Option(option.Option(a)),
  converter: fn(a) -> Value,
  null_value: Value,
) -> List(#(String, Value)) {
  case value {
    Some(Some(v)) -> [#(field, converter(v)), ..acc]
    Some(None) -> [#(field, null_value), ..acc]
    None -> acc
  }
}