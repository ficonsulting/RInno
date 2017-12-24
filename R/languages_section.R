#' Languages Section of ISS
#'
#' RInno currently supports 25 languages. Check the \code{languages} directory of Inno Setup for a complete list, and see \href{http://www.jrsoftware.org/ishelp/topic_languagessection.htm}{[Languages] section} for details.
#'
#' @param language Character vector of lower case languages to include.
#'
#' @inherit setup_section return params
#' @author Jonathan M. Hill
#' @export
languages_section <- function(iss, language = "english") {

  language <- tolower(language)

  supported_languages <- c("english",
    "brazilianportuguese",
    "catalan",
    "corsican",
    "czech",
    "danish",
    "dutch",
    "finnish",
    "french",
    "german",
    "greek",
    "hebrew",
    "hungarian",
    "italian",
    "japanese",
    "norwegian",
    "polish",
    "portuguese",
    "russian",
    "scottishgaelic",
    "serbiancyrillic",
    "serbianlatin",
    "slovenian",
    "spanish",
    "turkish",
    "ukrainian")

  unsupported_language <- language[!language %in% supported_languages]

  if (!all(language %in% supported_languages)) {
    stop(glue::glue("{unsupported_language} is not supported."))
  }

  opts <- c('Name: "english"; MessagesFile: "compiler:Default.isl"',
  'Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\\BrazilianPortuguese.isl"',
  'Name: "catalan"; MessagesFile: "compiler:Languages\\Catalan.isl"',
  'Name: "corsican"; MessagesFile: "compiler:Languages\\Corsican.isl"',
  'Name: "czech"; MessagesFile: "compiler:Languages\\Czech.isl"',
  'Name: "danish"; MessagesFile: "compiler:Languages\\Danish.isl"',
  'Name: "dutch"; MessagesFile: "compiler:Languages\\Dutch.isl"',
  'Name: "finnish"; MessagesFile: "compiler:Languages\\Finnish.isl"',
  'Name: "french"; MessagesFile: "compiler:Languages\\French.isl"',
  'Name: "german"; MessagesFile: "compiler:Languages\\German.isl"',
  'Name: "greek"; MessagesFile: "compiler:Languages\\Greek.isl"',
  'Name: "hebrew"; MessagesFile: "compiler:Languages\\Hebrew.isl"',
  'Name: "hungarian"; MessagesFile: "compiler:Languages\\Hungarian.isl"',
  'Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"',
  'Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"',
  'Name: "norwegian"; MessagesFile: "compiler:Languages\\Norwegian.isl"',
  'Name: "polish"; MessagesFile: "compiler:Languages\\Polish.isl"',
  'Name: "portuguese"; MessagesFile: "compiler:Languages\\Portuguese.isl"',
  'Name: "russian"; MessagesFile: "compiler:Languages\\Russian.isl"',
  'Name: "scottishgaelic"; MessagesFile: "compiler:Languages\\ScottishGaelic.isl"',
  'Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\\SerbianCyrillic.isl"',
  'Name: "serbianlatin"; MessagesFile: "compiler:Languages\\SerbianLatin.isl"',
  'Name: "slovenian"; MessagesFile: "compiler:Languages\\Slovenian.isl"',
  'Name: "spanish"; MessagesFile: "compiler:Languages\\Spanish.isl"',
  'Name: "turkish"; MessagesFile: "compiler:Languages\\Turkish.isl"',
  'Name: "ukrainian"; MessagesFile: "compiler:Languages\\Ukrainian.isl"')

  selected_opts <- opts[supported_languages %in% language]

  glue::glue("
    {iss}

    [Languages]
    {selected_opts}")
}
