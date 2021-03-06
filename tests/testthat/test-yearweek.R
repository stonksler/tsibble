x <- yearweek(as.Date("1970-01-01")) + 0:2
dates <- seq(as.Date("1969-12-29"), length.out = 3, by = "1 week") + 0
dttm <- .POSIXct(as.POSIXct(dates), tz = "UTC")

test_that("is_53weeks()", {
  expect_equal(is_53weeks(NULL), FALSE)
  expect_equal(is_53weeks(2015:2016), c(TRUE, FALSE))
  expect_error(is_53weeks("2015"), "positive integers.")
  expect_equal(is_53weeks(1969), FALSE)
  expect_equal(is_53weeks(1969, week_start = 7), TRUE)
})

test_that("input types for yearweek()", {
  expect_identical(yearweek(1:3), yearweek("1970 W1") + 1:3)
  expect_identical(yearweek(dttm), x)
  expect_identical(yearweek(dates), x)
  expect_identical(yearweek(x), x)
  expect_identical(yearweek(), x[0])
})

test_that("character type for yearweek()", {
  expect_error(yearweek("2013 We 3"), "cannot be expressed as Date type")
  expect_error(yearweek("Wee 5 2015"), "cannot be expressed as Date type")
  expect_error(yearweek("W54 2015"), "can't be greater than 53.")
  expect_error(yearweek(c("2015 W53", "2016 W53", "2017 W53")), "can't be 53 weeks.")
  expect_error(yearweek("W2015"), "unambiguous")
  expect_error(yearweek(c("W2015", "W2 2015")), "unambiguous")
  expect_identical(
    yearweek(c("2013 W3", "2013 Wk 3", "Week 3 2013")),
    rep(yearweek("2013 W03"), 3)
  )
})

test_that("yearweek.character() underlying dates", {
  expect_equal(as.Date(yearweek("1970 W01")), as.Date("1969-12-29"))
  expect_equal(
    as.Date(yearweek("1970 W01", week_start = 7)),
    as.Date("1970-01-04"))
  expect_equal(as.Date(yearweek("2019 W12")), as.Date("2019-03-18"))
})

test_that("vec_arith() for yearweek()", {
  expect_identical(x + 1:3, yearweek(c("1970 W02", "1970 W04", "1970 W06")))
  expect_identical(x - 1, yearweek(c("1969 W52", "1970 W01", "1970 W02")))
  expect_identical(+ x, x)
  expect_identical(- x, x)
  expect_identical(1 + x, x + 1)
  expect_identical(x - x, as.difftime(rep(0, 3), units = "weeks"))
  expect_error(x + x, class = "vctrs_error_incompatible_op")
})

test_that("vec_compare() for yearweek()", {
  expect_identical(x == yearweek("1970 W02"), c(FALSE, TRUE, FALSE))
  expect_identical(x <= yearweek("1970 W02"), c(TRUE, TRUE, FALSE))
  expect_identical(x > yearweek("1970 W02"), c(FALSE, FALSE, TRUE))
  expect_identical(sort(x), x)
})

test_that("vec_cast() for yearweek()", {
  expect_identical(as.Date(x), dates)
  expect_identical(as.character(x), format(x))
  expect_identical(vec_cast(x, to = double()), as.double(x))
  expect_identical(vec_cast(x, to = new_date()), dates)
  expect_identical(.POSIXct(as.POSIXct(x), tz = "UTC"), dttm)
  expect_identical(as.POSIXlt(x), as.POSIXlt(dttm))
  expect_identical(.POSIXct(vec_cast(x, to = new_datetime()), tz = "UTC"), dttm)
})

test_that("vec_c() for yearweek()", {
  expect_error(c(x, yearweek(0, 7)), "combine")
  expect_identical(vec_c(dates, x), rep(dates, times = 2))
  expect_identical(vec_c(x, dates), rep(dates, times = 2))
  expect_identical(vec_data(vec_c(dttm, x)), vec_data(rep(dttm, times = 2)))
  expect_identical(vec_data(vec_c(x, dttm)), vec_data(rep(dttm, times = 2)))
  expect_identical(vec_c(dates, x), c(dates, x))
})

test_that("year() for extracting correct year #161", {
  expect_equal(year(yearweek("1992 W01")), 1992)
  date <- as.Date("1969-12-29")
  expect_equal(year(yearweek(date, week_start = 7)), 1969)
  expect_equal(year(yearweek(date, week_start = 1)), 1970)
})

test_that("format.yearweek() with NA presence", {
  expect_equal(format(c(yearweek("1970 W1"), NA)), c("1970 W01", NA))
})

x2 <- yearweek(as.Date("1970-01-01"), week_start = 7) + 0:2
dates2 <- seq(as.Date("1969-12-28"), length.out = 3, by = "1 week") + 0
dttm2 <- .POSIXct(as.POSIXct(dates2), tz = "UTC")

test_that("week_start for yearweek() #205", {
  expect_error(yearweek(1:3, 1:3), "length 1.")
  expect_error(yearweek(1:3, 8), "between")
  expect_identical(yearweek(1:3, 7), yearweek("1970 W1", 7) + 1:3)
  expect_identical(yearweek(dttm2, 7), x2)
  expect_identical(yearweek(dates2, 7), x2)
  expect_identical(
    yearweek(x2, week_start = 1),
    yearweek(c("1969 W52", "1970 W01", "1970 W02"), week_start = 1))

  expect_identical(x2 + 1:3, yearweek(c("1970 W01", "1970 W03", "1970 W05"), 7))
  expect_identical(x2 - 1, yearweek(c("1969 W52", "1969 W53", "1970 W01"), 7))
  expect_identical(+ x2, x2)
  expect_identical(- x2, x2)
  expect_identical(1 + x2, x2 + 1)

  expect_identical(as.Date(x2), dates2)
  expect_identical(as.character(x2), format(x2))
  expect_identical(vec_cast(x2, to = double()), as.double(x2))
  expect_identical(vec_cast(x2, to = new_date()), dates2)
  expect_identical(.POSIXct(as.POSIXct(x2), tz = "UTC"), dttm2)
  expect_identical(as.POSIXlt(x2), as.POSIXlt(dttm2))
  expect_identical(.POSIXct(vec_cast(x2, to = new_datetime()), tz = "UTC"), dttm2)
})

test_that("yearweek() with missing `by` #228", {
  expect_length(seq(yearweek("2020-01-01"), yearweek("2020-02-01"),
    length.out = 3), 3)
})

test_that("yearweek() set operations", {
  expect_identical(
    intersect(yearweek("2020 W1") + 0:6, yearweek("2020 W1") + 3:9),
    yearweek("2020 W1") + intersect(0:6, 3:9))

  expect_error(intersect(
    yearweek("2020 W1"),
    yearweek("2020 W1", week_start = 2)
  ))

  expect_identical(
    union(yearweek("2020 W1") + 0:6, yearweek("2020 W1") + 3:9),
    yearweek("2020 W1") + 0:9)

  expect_error(union(
    yearweek("2020 W1"),
    yearweek("2020 W1", week_start = 2)
  ))

  expect_identical(
    setdiff(yearweek("2020 W1") + 0:6, yearweek("2020 W1") + 3:9),
    yearweek("2020 W1") + setdiff(0:6, 3:9))
  expect_error(setdiff(
    yearweek("2020 W1"),
    yearweek("2020 W1", week_start = 2)
  ))
})
