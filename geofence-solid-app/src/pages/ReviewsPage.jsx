// src/pages/ReviewsPage.jsx
import { createSignal, onMount, For, Show } from "solid-js";
import { api } from "../lib/api";

export default function ReviewsPage() {
  const [reviews, setReviews] = createSignal([]);
  const [loading, setLoading] = createSignal(true);

  onMount(async () => {
    setLoading(true);
    try {
      const data = await api.getReviews();
      setReviews(data);
    } catch (error) {
      console.error("Failed to load reviews:", error);
    }
    setLoading(false);
  });

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString();
  };

  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Reviews</h1>
          <p class="page-subtitle">Verified customer reviews</p>
        </div>
      </div>

      <Show
        when={!loading()}
        fallback={<div class="loading">Loading reviews...</div>}
      >
        <Show
          when={reviews().length > 0}
          fallback={
            <div class="empty-state">
              <svg
                class="empty-icon"
                viewBox="0 0 24"
                fill="none"
                stroke="currentColor"
              >
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
              </svg>
              <h3 class="empty-title">No reviews yet</h3>
              <p class="empty-text">
                Customer reviews will appear here once they start visiting.
              </p>
            </div>
          }
        >
          <div class="reviews-list">
            <For each={reviews()}>
              {(review) => (
                <div class="review-card">
                  <div class="review-header">
                    <span class="review-rating">
                      {review.rating.toFixed(1)} ★
                    </span>
                    <span class="review-customer">
                      {review.customers?.name || "A Customer"}
                    </span>
                  </div>
                  <p class="review-comment">{review.comment}</p>
                  <div class="review-footer">
                    <span class="review-location">
                      {review.locations?.name || "A Location"}
                    </span>
                    <span class="review-date">
                      {formatDate(review.created_at)}
                    </span>
                  </div>
                </div>
              )}
            </For>
          </div>
        </Show>
      </Show>
    </div>
  );
}
