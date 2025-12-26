import pytest
from app.classification import classify_task

class TestCategoryClassification:
    def test_scheduling_category(self):
        result = classify_task(
            "Schedule meeting",
            "Need to arrange a meeting with the team next week"
        )
        assert result["category"] == "scheduling"
    
    def test_finance_category(self):
        result = classify_task(
            "Process payment",
            "Need to handle invoice and billing for this month"
        )
        assert result["category"] == "finance"
    
    def test_technical_category(self):
        result = classify_task(
            "Fix bug",
            "There's a critical bug in the code that needs debugging"
        )
        assert result["category"] == "technical"
    
    def test_safety_category(self):
        result = classify_task(
            "Safety inspection",
            "Conduct safety audit and compliance check"
        )
        assert result["category"] == "safety"
    
    def test_general_category(self):
        result = classify_task(
            "Random task",
            "This is just a regular task without specific keywords"
        )
        assert result["category"] == "general"

class TestPriorityClassification:
    def test_high_priority(self):
        result = classify_task(
            "Urgent fix",
            "This is critical and must be done ASAP"
        )
        assert result["priority"] == "high"
    
    def test_medium_priority(self):
        result = classify_task(
            "Regular task",
            "This is a standard task that needs to be done"
        )
        assert result["priority"] == "medium"
    
    def test_low_priority(self):
        result = classify_task(
            "Future enhancement",
            "This is optional and can be done later when possible"
        )
        assert result["priority"] == "low"

class TestSuggestedActions:
    def test_suggested_actions_exist(self):
        result = classify_task(
            "Schedule meeting",
            "Need to arrange a meeting"
        )
        assert "suggested_actions" in result
        assert len(result["suggested_actions"]) > 0
        assert isinstance(result["suggested_actions"], list)
    
    def test_suggested_actions_match_category(self):
        result = classify_task(
            "Process payment",
            "Handle invoice and billing"
        )
        assert result["category"] == "finance"
        assert len(result["suggested_actions"]) > 0
