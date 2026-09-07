export class DateHelper {
  static getCurrentDateString(): string {
    return DateHelper.formatDateKey(new Date());
  }

  static formatDateKey(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static formatDisplayDate(date: Date): string {
    const month = date.getMonth() + 1;
    const day = date.getDate();

    const today = new Date();
    const todayKey = DateHelper.formatDateKey(today);
    const dateKey = DateHelper.formatDateKey(date);

    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const yesterdayKey = DateHelper.formatDateKey(yesterday);

    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
    const tomorrowKey = DateHelper.formatDateKey(tomorrow);

    let suffix = '';
    if (dateKey === todayKey) {
      suffix = '今天';
    } else if (dateKey === yesterdayKey) {
      suffix = '昨天';
    } else if (dateKey === tomorrowKey) {
      suffix = '明天';
    } else {
      const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
      suffix = weekdays[date.getDay()];
    }

    return `${month}月${day}日 ${suffix}`;
  }

  static addDays(date: Date, days: number): Date {
    const newDate = new Date(date.getTime());
    newDate.setDate(newDate.getDate() + days);
    return newDate;
  }
}
