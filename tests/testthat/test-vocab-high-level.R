context("vocabulary-corpus parallel")

get_test_iterator = function(txt, ids)
  itoken(txt,
         preprocess_function = tolower,
         tokenizer = word_tokenizer,
         ids = ids,
         progressbar = FALSE)

N_WORKER = 4

train_ind = 1:1000
txt = movie_review[['review']][train_ind]
ids = movie_review[['id']][train_ind]

txt_splits = split_into(txt, N_WORKER)
ids_splits = split_into(ids, N_WORKER)

test_that("Vocabulary with foreach", {
  iterator = get_test_iterator(txt, ids)
  vocab_1 = create_vocabulary(iterator)

  iterator_list = mapply(function(x, i) get_test_iterator(x, i), txt_splits, ids_splits)
  expect_warning(vocab_2 <- create_vocabulary(iterator_list))

  expect_equal(sort(vocab_1$term),  sort(vocab_2$term))
  expect_equal(attr(vocab_1, "document_count"),  attr(vocab_2, "document_count"))
  expect_equal(attr(vocab_1, "document_count"),  max(train_ind))
  expect_equal(attr(vocab_1, "ngram"), attr(vocab_2, "ngram"))

  expect_warning(dtm11 <- create_dtm(iterator_list, vocab_vectorizer(vocab_1)))
  expect_equal(create_dtm(iterator, vocab_vectorizer(vocab_1)), dtm11)
})


train_ind = 1:100
txt = movie_review[['review']][train_ind]
ids = movie_review[['id']][train_ind]

train_ind_1 = 1:50
txt_1 = movie_review[['review']][train_ind_1]
ids_1 = movie_review[['id']][train_ind_1]

train_ind_2 = 51:100
txt_2 = movie_review[['review']][train_ind_2]
ids_2 = movie_review[['id']][train_ind_2]

test_that("combine vocabularies", {

  iterator = get_test_iterator(txt, ids)
  vocab = create_vocabulary(iterator, ngram = c(1, 2), stopwords = c("a", "the"), sep_ngram = "_")

  iterator_1 = get_test_iterator(txt_1, ids_1)
  vocab_1 = create_vocabulary(iterator_1, ngram = c(1, 2), stopwords = c("a", "the"), sep_ngram = "_")

  iterator_2 = get_test_iterator(txt_2, ids_2)
  vocab_2 = create_vocabulary(iterator_2, ngram = c(1, 2), stopwords = c("a", "the"), sep_ngram = "_")

  vocab_combined = combine_vocabularies(vocab_1, vocab_2)

  expect_equal(vocab_combined, vocab)
})
