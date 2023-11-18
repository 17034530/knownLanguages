<script>
  import {navigate} from "svelte-routing";
</script>

<main>
  <h2>Page not found</h2>
  <button on:click={() => navigate("/")}>Back</button>
</main>
