# Wikipedia API Integration

## Що було реалізовано

✅ **WikipediaClient** - клієнт для отримання описів спорту з Wikipedia
✅ **Автоматичне завантаження** - описи завантажуються автоматично при появі елементів
✅ **Мапінг назв** - автоматичне перетворення назв спорту на назви статей Wikipedia
✅ **Fallback** - якщо Wikipedia не знаходить статтю, використовується оригінальний опис

## Як це працює

### 1. Мапінг назв спорту на Wikipedia статті:
- "Aerobatic Flying" → "Aerobatics"
- "Glider Racing" → "Gliding" 
- "Skydiving Formation" → "Parachuting"
- "Hot Air Balloon Racing" → "Hot air balloon"
- "Air Racing" → "Air racing"
- "Formation Flying" → "Formation flying"
- "Precision Landing" → "Precision flying"
- "Wing Walking" → "Wing walking"
- "Helicopter Precision" → "Helicopter"
- "Ultralight Racing" → "Ultralight aviation"
- "Paragliding Cross Country" → "Paragliding"
- "Base Jumping" → "BASE jumping"
- "Hang Gliding Racing" → "Hang gliding"
- "Helicopter Slalom" → "Slalom"
- "Aerobatic Solo" → "Solo flight"

### 2. API Endpoint:
```
https://en.wikipedia.org/api/rest_v1/page/summary/{назва_статті}
```

### 3. Приклад відповіді:
```json
{
  "extract": "Aerobatics is the practice of flying maneuvers involving aircraft attitudes that are not used in conventional passenger-carrying flights...",
  "title": "Aerobatics",
  "thumbnail": {
    "source": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Frecce_Tricolori_2022.jpg/330px-Frecce_Tricolori_2022.jpg"
  }
}
```

## Переваги Wikipedia API

✅ **Безкоштовно** - не потрібен API ключ
✅ **Надійно** - Wikipedia має високу доступність
✅ **Актуально** - інформація постійно оновлюється
✅ **Детально** - професійні описи з експертних джерел
✅ **Багатомовно** - можна легко додати інші мови

## Особливості реалізації

- **Асинхронне завантаження** - описи завантажуються в фоновому режимі
- **Кешування** - SwiftUI автоматично кешує відповіді
- **Обробка помилок** - якщо Wikipedia недоступна, використовується оригінальний опис
- **Продуктивність** - запити виконуються тільки при появі елементів

## Тестування

1. Запустіть додаток
2. Перейдіть на вкладку "Aviation Sports"
3. Прокрутіть список - описи повинні автоматично оновлюватися з Wikipedia
4. Перевірте різні категорії спорту

## Майбутні покращення

- Додати підтримку інших мов (українська, німецька, французька)
- Використовувати thumbnail зображення з Wikipedia
- Додати посилання на повну статтю Wikipedia
- Кешувати описи локально для офлайн режиму
