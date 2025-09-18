# Wikipedia Images Integration для Aviator_v5

## 📸 Що ми додали:

### 1. **WikipediaImageClient** - новий сервіс
- Отримує зображення пілотів з Wikipedia API
- Використовує REST API: `https://en.wikipedia.org/api/rest_v1/page/summary/{pilot_name}`
- Повертає URL зображення з Wikipedia Commons

### 2. **Оновлена модель Pilot**
- Додано поле `imageURL: URL?`
- Зберігає посилання на зображення з Wikipedia

### 3. **Оновлений PilotsFeature**
- Асинхронне завантаження зображень при запуску
- Обробка помилок при завантаженні зображень
- Fallback до плейсхолдера, якщо зображення не знайдено

### 4. **Оновлений UI**
- **PilotRowView**: AsyncImage для списку пілотів
- **PilotDetailView**: Велике зображення в детальному перегляді
- Плейсхолдери з іконками, якщо зображення недоступні

## 🔧 Як це працює:

1. **При запуску** додаток завантажує базові дані пілотів
2. **Для кожного пілота** робить запит до Wikipedia API
3. **Отримує URL зображення** з відповіді API
4. **Відображає зображення** в UI з AsyncImage
5. **Fallback** до плейсхолдера, якщо зображення недоступне

## 📊 Тестовані пілоти:

✅ **Amelia Earhart** - є зображення  
✅ **Neil Armstrong** - є зображення  
✅ **Yuri Gagarin** - є зображення  

## 🎯 Переваги:

- **Безкоштовні зображення** з Wikipedia Commons
- **Висока якість** зображень
- **Автоматичне оновлення** при змінах в Wikipedia
- **Fallback система** для недоступних зображень
- **Кешування** через AsyncImage

## 📝 Ліцензія:

Всі зображення з Wikipedia Commons мають ліцензію Creative Commons, що дозволяє їх використання в комерційних проектах за умови вказівки авторства.

## 🚀 Використання:

```swift
// Завантаження зображення пілота
let imageURL = try await wikipediaImageClient.fetchPilotImage("Amelia Earhart")

// Відображення в UI
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 60, height: 60)
        .clipShape(Circle())
} placeholder: {
    // Плейсхолдер
}
```

## 🔍 Приклад API запиту:

```bash
curl "https://en.wikipedia.org/api/rest_v1/page/summary/Amelia_Earhart" | jq '.thumbnail.source'
```

**Відповідь:**
```json
"https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Amelia_Earhart_standing_under_nose_of_her_Lockheed_Model_10-E_Electra%2C_small_%28cropped%29.jpg/330px-Amelia_Earhart_standing_under_nose_of_her_Lockheed_Model_10-E_Electra%2C_small_%28cropped%29.jpg"
```
