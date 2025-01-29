Parse.Cloud.define("sayHi", async (request) => {
  return "Hello from Cloud Code!";
});

Parse.Cloud.define("sayBye", async (request) => {
  return "Bye from Cloud Code!";
});

Parse.Cloud.define("createPost", async (request) => {
  const { postTitle, sections } = request.params;

  // Ensure the user is authenticated
  const user = request.user;
  if (!user) {
    throw new Parse.Error(401, "You must be logged in to create a post.");
  }

  // Create a new Post object
  const Post = Parse.Object.extend("Posts");
  const post = new Post();

  // Set the post data
  post.set("postTitle", postTitle);
  post.set("sections", sections);
  post.set("user", user); // Associate the post with the user

  // Save the post
  try {
    const savedPost = await post.save();
    return savedPost;
  } catch (error) {
    throw new Parse.Error(500, `Failed to create post: ${error.message}`);
  }
});
