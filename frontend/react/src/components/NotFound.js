function NotFound() {
  return (
    <div>
      Page not found <button onClick={() => (window.location.href = "/")}>Back</button>
    </div>
  )
}

export default NotFound