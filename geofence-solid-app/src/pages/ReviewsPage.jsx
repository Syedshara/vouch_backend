export default function ReviewsPage() {
  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Reviews</h1>
          <p class="page-subtitle">Verified customer reviews</p>
        </div>
      </div>

      <div class="empty-state">
        <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
        </svg>
        <h3 class="empty-title">No reviews yet</h3>
        <p class="empty-text">Customer reviews will appear here once they start visiting</p>
      </div>
    </div>
  )
}
