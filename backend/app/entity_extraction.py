import re
from typing import Dict, List
from dateutil import parser as date_parser

DATE_PATTERNS = [
    r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}',
    r'\d{4}[/-]\d{1,2}[/-]\d{1,2}',
    r'(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}',
    r'\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}',
    r'today|tomorrow|yesterday|next week|next month',
    r'\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?',
]

PERSON_KEYWORDS = [
    r'with\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
    r'by\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
    r'assign(?:ed)?\s+to\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
    r'contact\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
    r'meet\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
]

def extract_dates(text: str) -> List[str]:
    dates = []
    
    for pattern in DATE_PATTERNS:
        matches = re.findall(pattern, text, re.IGNORECASE)
        dates.extend(matches)
    
    words = text.split()
    for i, word in enumerate(words):
        if any(char.isdigit() for char in word):
            context = ' '.join(words[max(0, i-2):i+3])
            try:
                parsed = date_parser.parse(context, fuzzy=True)
                date_str = parsed.strftime('%Y-%m-%d')
                if date_str not in dates:
                    dates.append(date_str)
            except:
                pass
    
    return list(set(dates))

def extract_people(text: str) -> List[str]:
    people = []
    
    for pattern in PERSON_KEYWORDS:
        matches = re.findall(pattern, text, re.IGNORECASE)
        for match in matches:
            if isinstance(match, tuple):
                match = match[0] if match else ""
            if match and match not in people:
                if match[0].isupper() and len(match) > 1:
                    people.append(match.strip())
    
    return people

def extract_entities(title: str, description: str) -> Dict:
    combined_text = f"{title} {description}"
    dates = extract_dates(combined_text)
    people = extract_people(combined_text)
    
    return {
        "dates": dates,
        "people": people
    }
