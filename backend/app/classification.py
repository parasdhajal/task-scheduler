from typing import Dict, List

CATEGORY_KEYWORDS = {
    "scheduling": [
        "meeting", "schedule", "appointment", "calendar", "time", "date",
        "deadline", "reminder", "book", "reserve", "plan", "arrange",
        "coordinate", "organize", "timeline", "agenda"
    ],
    "finance": [
        "budget", "payment", "invoice", "expense", "cost", "price", "money",
        "financial", "accounting", "billing", "revenue", "profit", "tax",
        "salary", "payroll", "transaction", "refund", "purchase", "buy"
    ],
    "technical": [
        "code", "develop", "programming", "bug", "fix", "deploy", "server",
        "database", "api", "system", "software", "hardware", "technical",
        "implementation", "testing", "debug", "maintenance", "upgrade",
        "integration", "configuration", "setup", "install"
    ],
    "safety": [
        "safety", "security", "compliance", "audit", "risk", "hazard",
        "emergency", "protocol", "inspection", "certification", "training",
        "accident", "prevention", "protection", "fire", "health", "safety check"
    ],
    "general": []
}

PRIORITY_KEYWORDS = {
    "high": [
        "urgent", "critical", "emergency", "asap", "immediate", "important",
        "priority", "deadline", "must", "essential", "vital", "crucial"
    ],
    "medium": [
        "soon", "moderate", "normal", "standard", "regular"
    ],
    "low": [
        "later", "optional", "when possible", "nice to have", "low priority",
        "backlog", "future"
    ]
}

SUGGESTED_ACTIONS = {
    "scheduling": [
        "Check calendar availability",
        "Send meeting invites",
        "Set reminders",
        "Confirm time with participants"
    ],
    "finance": [
        "Review budget allocation",
        "Process payment",
        "Update financial records",
        "Generate invoice/receipt"
    ],
    "technical": [
        "Review code changes",
        "Run tests",
        "Update documentation",
        "Deploy to staging"
    ],
    "safety": [
        "Conduct safety inspection",
        "Review compliance checklist",
        "Schedule training session",
        "Update safety protocols"
    ],
    "general": [
        "Review task details",
        "Assign resources",
        "Set timeline",
        "Follow up"
    ]
}

def classify_category(text: str) -> str:
    text_lower = text.lower()
    category_scores = {}
    
    for category, keywords in CATEGORY_KEYWORDS.items():
        if category == "general":
            continue
        score = sum(1 for keyword in keywords if keyword in text_lower)
        if score > 0:
            category_scores[category] = score
    
    if category_scores:
        return max(category_scores, key=category_scores.get)
    return "general"

def classify_priority(text: str) -> str:
    text_lower = text.lower()
    
    for keyword in PRIORITY_KEYWORDS["high"]:
        if keyword in text_lower:
            return "high"
    
    for keyword in PRIORITY_KEYWORDS["low"]:
        if keyword in text_lower:
            return "low"
            
    return "medium"

def classify_task(title: str, description: str) -> Dict:
    combined_text = f"{title} {description}"
    
    category = classify_category(combined_text)
    priority = classify_priority(combined_text)
    
    return {
        "category": category,
        "priority": priority,
        "suggested_actions": SUGGESTED_ACTIONS.get(category, [])
    }
