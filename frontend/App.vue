<template>
  <div id="app">
    <div class="header">
      <div class="dropdown">
        <button class="dropdown-btn">筛选事件</button>
        <div class="dropdown-content">
          <label>
            <input type="checkbox" v-model="allEventsSelected">
            All
          </label>
          <hr class="separator">
          <label v-for="eventType in eventTypes" :key="eventType">
            <input type="checkbox" :value="eventType" v-model="selectedEventTypes">
            {{ enumEventShortNames[eventType] || eventType }}
          </label>
        </div>
      </div>
      <a href="https://github.com/lslightly/github-follow-contributions" target="_blank"
        style="color: black; text-decoration: none;">
        <svg width="1.2em" height="1.2em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 1024 1024"
          style="font-size: xx-large;">
          <path fill="currentColor"
            d="M511.6 76.3C264.3 76.2 64 276.4 64 523.5C64 718.9 189.3 885 363.8 946c23.5 5.9 19.9-10.8 19.9-22.2v-77.5c-135.7 15.9-141.2-73.9-150.3-88.9C215 726 171.5 718 184.5 703c30.9-15.9 62.4 4 98.9 57.9c26.4 39.1 77.9 32.5 104 26c5.7-23.5 17.9-44.5 34.7-60.8c-140.6-25.2-199.2-111-199.2-213c0-49.5 16.3-95 48.3-131.7c-20.4-60.5 1.9-112.3 4.9-120c58.1-5.2 118.5 41.6 123.2 45.3c33-8.9 70.7-13.6 112.9-13.6c42.4 0 80.2 4.9 113.5 13.9c11.3-8.6 67.3-48.8 121.3-43.9c2.9 7.7 24.7 58.3 5.5 118c32.4 36.8 48.9 82.7 48.9 132.3c0 102.2-59 188.1-200 212.9a127.5 127.5 0 0 1 38.1 91v112.5c.8 9 0 17.9 15 17.9c177.1-59.7 304.6-227 304.6-424.1c0-247.2-200.4-447.3-447.5-447.3z">
          </path>
        </svg>
      </a>
    </div>
    <div class="legend">
      <div v-for="(eventList, categoryName) in topicCategories" :key="categoryName" class="legend-item">
        <span class="legend-title summary-tag" :class="`summary-tag-${categoryName}`">{{ categoryName }}</span>
        <span class="legend-arrow">→</span>
        <div class="legend-events-container">
          <span v-for="event in eventList" :key="event" class="legend-event">{{ event }}</span>
        </div>
      </div>
      <p class="legend-tip">将鼠标悬浮在tag上以获得总结。</p>
    </div>
    <div v-for="userObj in filteredUsers" :key="Object.keys(userObj)[0]">
      <div class="user-card">
        <div class="user-header">
          <div class="user-info">
            <img :src="'https://github.com/' + userObj.username + '.png'" :alt="userObj.username + '的头像'"
              class="avatar">
            <a :href="'https://github.com/' + userObj.username" class="username" target="_blank">
              {{ userObj.username }}
            </a>
          </div>
          <div class="summary-tags">
            <div class="summary-category">
              <span class="summary-tag summary-tag-work tooltip">
                work
                <span class="tooltip-text summary-tooltip-text">{{ userObj.summary_topics.work }}</span>
              </span>
              <span class="summary-tag summary-tag-discuss tooltip">
                discuss
                <span class="tooltip-text summary-tooltip-text">{{ userObj.summary_topics.discuss }}</span>
              </span>
              <span class="summary-tag summary-tag-watch tooltip">
                watch
                <span class="tooltip-text summary-tooltip-text">{{ userObj.summary_topics.watch }}</span>
              </span>
            </div>
          </div>
        </div>
        <div>
          <div v-for="[repoName, eventTypes] in getGroupedEvents(userObj.events)" :key="repoName" class="event-item">
            <a :href="'https://github.com/' + repoName" class="event-repo" target="_blank">{{ repoName }}</a>
            <div>
              <span v-for="(payloads, eventType) in eventTypes" :key="eventType" class="event-type tooltip"
                :style="enumEventTypeStyles[eventType]">
                {{ enumEventShortNames[eventType] || eventType }}
                <div class="tooltip-text">
                  <a v-for="(item, index) in generateTooltipContent(eventType, payloads, repoName)" :key="index"
                    :href="item.href" target="_blank" style="color: #333; text-decoration: none; margin: 2px 4px;">
                    {{ item.text }}
                  </a>
                </div>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      users: [],
      eventTypes: [],
      selectedEventTypes: [],
      topicCategories: {
        work: ['CreateEvent', 'PushEvent', 'PullRequestEvent'],
        discuss: ['IssuesEvent', 'IssueCommentEvent', 'PullRequestReviewEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewThreadEvent'],
        watch: ['ForkEvent', 'WatchEvent']
      },
      enumEventTypeStyles: {
        WatchEvent: { backgroundColor: '#e3fcec', color: '#026034' },
        PushEvent: { backgroundColor: '#ddf4ff', color: '#0550ae' },
        IssuesEvent: { backgroundColor: '#f1f8ff', color: '#0366d6' },
        PullRequestEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        PullRequestReviewEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        PullRequestReviewCommentEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        DeleteEvent: { backgroundColor: '#f1f8ff', color: '#0366d6' },
        IssueCommentEvent: { backgroundColor: '#f1f8ff', color: '#0366d6' },
        CreateEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        CommitCommentEvent: { backgroundColor: '#f1f8ff', color: '#0366d6' },
        MemberEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        ForkEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        ReleaseEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        GollumEvent: { backgroundColor: '#f0f8ff', color: '#0366d6' },
        PublicEvent: { backgroundColor: '#f1f8ff', color: '#0366d6' },
      },
      enumEventShortNames: {
        WatchEvent: 'Watch',
        PushEvent: 'Push',
        IssuesEvent: 'Issue',
        PullRequestEvent: 'PR',
        PullRequestReviewEvent: 'Review',
        PullRequestReviewCommentEvent: 'PRComment',
        DeleteEvent: 'Delete',
        IssueCommentEvent: 'IssueComment',
        CreateEvent: 'Create',
        CommitCommentEvent: 'CommitComment',
        MemberEvent: 'Member',
        ForkEvent: 'Fork',
        ReleaseEvent: 'Release',
        GollumEvent: 'Gollum',
        PublicEvent: 'Public',
      }
    }
  },
  methods: {
    getGroupedEvents(events) {
      const eventMap = {};
      events.forEach(event => {
        const [repoName, eventType, eventPayload] = event;
        if (!eventMap[repoName]) {
          eventMap[repoName] = {};
        }
        if (!eventMap[repoName][eventType]) {
          eventMap[repoName][eventType] = []
        }
        eventMap[repoName][eventType].push(eventPayload);
      });
      return Object.entries(eventMap);
    },
    generateTooltipContent(eventType, payloads, repoName) {
      const limitedPayloads = payloads.slice(0, 5);
      switch (eventType) {
        case 'WatchEvent':
          return [{ text: 'Watch' }];
        case 'PushEvent':
          return limitedPayloads.map(p => ({
            text: p.head ? p.head.slice(0, 6) : '',
            href: `https://github.com/${repoName}/tree/${p.head}`
          })).filter(p => p.text);
        case 'IssuesEvent':
          return limitedPayloads.map(p => ({
            text: `#${p.issue.number}`,
            href: p.issue.html_url
          }));
        case 'PullRequestEvent':
        case 'PullRequestReviewEvent':
          return limitedPayloads.map(p => ({
            text: `#${p.pull_request.number}`,
            href: p.pull_request.html_url
          }));
        case 'PullRequestReviewCommentEvent':
          return limitedPayloads.map(p => ({
            text: `#${p.pull_request.number}`,
            href: p.comment.html_url
          }));
        case 'DeleteEvent':
          return limitedPayloads.map(p => ({
            text: p.ref,
            href: `https://github.com/${repoName}/tree/${p.ref}`
          })).filter(p => p.text);
        case 'IssueCommentEvent':
          return limitedPayloads.map(p => ({
            text: `#${p.issue.number}`,
            href: p.comment.html_url
          }));
        case 'CreateEvent':
          return limitedPayloads.map(p => {
            if (p.ref_type !== 'repository') {
              return { text: p.ref, href: `https://github.com/${repoName}/tree/${p.ref}` };
            }
            return { text: repoName, href: `https://github.com/${repoName}` };
          }).filter(p => p.text);
        case 'ForkEvent':
          return payloads.map(p => ({
            text: p.forkee.full_name,
            href: `https://github.com/${p.forkee.full_name}`
          }));
        case 'ReleaseEvent':
          return payloads.map(p => ({
            text: p.release.name,
            href: p.release.html_url
          }));
        case 'CommitCommentEvent':
          return [{ text: 'CommitComment' }];
        case 'MemberEvent':
          return [{ text: 'Member' }];
        case 'GollumEvent':
          return [{ text: 'Gollum' }];
        case 'PublicEvent':
          return [{ text: 'Public' }];
        default:
          return [];
      }
    }
  },
  computed: {
    allEventsSelected: {
      get() {
        return this.eventTypes.length > 0 && this.selectedEventTypes.length === this.eventTypes.length;
      },
      set(value) {
        if (value) {
          this.selectedEventTypes = [...this.eventTypes];
        } else {
          this.selectedEventTypes = [];
        }
      }
    },
    filteredUsers() {
      return this.users.map(user => {
        const filteredEvents = user.events.filter(event => this.selectedEventTypes.includes(event[1]));
        return {
          ...user,
          events: filteredEvents
        };
      }).filter(user => user.events.length > 0);
    }
  },
  async created() {
    const data = await fetch("events.json").then(res => res.json());
    this.users = data;
    this.eventTypes = Object.keys(this.enumEventTypeStyles);
    this.selectedEventTypes = [...this.eventTypes];
  }
}
</script>

<style>
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
  max-width: 800px;
  margin: 20px auto;
  padding: 0 20px;
  background-color: #f6f8fa;
}

.legend {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  padding: 12px 16px;
  margin-bottom: 20px;
  font-size: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-arrow {
  color: #586069;
  font-weight: bold;
}

.legend-events-container {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 8px; /* Vertical and horizontal gap */
}

.legend-title {
  font-weight: bold;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
}

.legend-event {
  background-color: #f3f4f6;
  padding: 2px 6px;
  border-radius: 12px;
  color: #586069;
}

.legend-tip {
  font-style: italic;
  color: #586069;
  padding-top: 8px;
  border-top: 1px solid #e1e4e8;
  margin-top: 8px;
}

.user-card {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  padding: 16px;
  margin-bottom: 20px;
}

.user-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 15px;
}

.user-info {
  display: flex;
  align-items: center;
}

.summary-tags {
  display: flex;
  gap: 8px;
  align-items: center;
}

.summary-category {
  display: flex;
  align-items: center;
  gap: 8px;
}

.summary-tag {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.summary-tag-work {
  background-color: #ddf4ff;
  color: #0550ae;
}

.summary-tag-discuss {
  background-color: #f1f8ff;
  color: #0366d6;
}

.summary-tag-watch {
  background-color: #e3fcec;
  color: #026034;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-right: 10px;
}

.username {
  font-size: 20px;
  font-weight: 600;
  color: #24292e;
}

.event-item {
  padding: 8px 0;
  border-bottom: 1px solid #eaecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.event-repo {
  color: #0366d6;
  font-weight: 500;
  margin-right: 1em;
  word-break: break-all;
}

.event-repo+div {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.event-type {
  background-color: #f3f4f6;
  padding: 2px 6px;
  margin: 4px;
  border-radius: 12px;
  font-size: 12px;
  color: #586069;
}

.dropdown {
  position: relative;
  display: inline-block;
  padding-bottom: 20px;
}

.dropdown-btn {
  background-color: #0366d6;
  color: white;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  border: none;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: white;
  min-width: 200px;
  box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.2);
  z-index: 1;
  margin-top: 5px;
  border-radius: 6px;
}

.separator {
  border: none;
  border-top: 1px solid #e1e4e8;
  margin: 4px 0;
}

.dropdown-content label {
  display: block;
  padding: 8px;
  cursor: pointer;
  font-size: 14px;
}

.dropdown-content input {
  margin-right: 8px;
}

.dropdown:hover .dropdown-content {
  display: block;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: start;
}

.tooltip {
  position: relative;
  display: inline-block;
}

.tooltip .tooltip-text {
  visibility: hidden;
  width: auto;
  background-color: #f9f9f9;
  /* Light background */
  color: #333;
  /* Dark text */
  text-align: center;
  border-radius: 6px;
  padding: 5px;
  position: absolute;
  z-index: 1;
  top: 125%; /* Change from bottom to top */
  left: 50%;
  transform: translateX(-50%);
  white-space: normal; /* Allow text to wrap */
  min-width: 200px; /* Set a min-width for better readability */
  max-width: 400px; /* Set a max-width to avoid overly wide tooltips */
  text-align: left;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  /* Subtle shadow */
  border: 1px solid #ddd;
  /* Light border */
}

.tooltip:hover .tooltip-text {
  visibility: visible;
}

.tooltip .tooltip-text::after {
  content: '';
  position: absolute;
  bottom: 100%; /* Change from top to bottom */
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: transparent transparent #f9f9f9 transparent; /* Flip the arrow */
  /* Match background */
}

.tooltip .tooltip-text a {
  display: inline-block;
  /* Allow wrapping */
  margin: 2px 4px;
  /* Add small gap between elements */
  text-decoration: none;
  /* Remove underline for links */
}
</style>