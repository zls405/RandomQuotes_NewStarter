namespace RandomQuotes.Models
{
    public class Quote
    {
        public int QuoteId { get; set; }
        public string QuoteText { get; set; }
        
        public int AuthorId { get; set; }
        public Author Author { get; set; }
    }
}
