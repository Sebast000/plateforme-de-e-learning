from django.urls import path
from .views import ForumTopicListCreateView, ForumMessageCreateView, ForumReplyCreateView

urlpatterns = [
    path("discussions/", ForumTopicListCreateView.as_view(), name="forum-topics-list-create"),
    path("topics/<int:topic_id>/message/", ForumMessageCreateView.as_view(), name="forum-message-create"),
    path("messages/<int:message_id>/reply/", ForumReplyCreateView.as_view(), name="forum-reply-create"),
]
