.PHONY: all clean
all: munges_wiki_page/actual_results/issue_1.html munges_wiki_page/actual_results/issue_2.html munges_wiki_page/actual_results/issue_3.html munges_wiki_page/actual_results/issue_4.html munges_wiki_page/actual_results/issue_5.html munges_wiki_page/actual_results/issue_6.html munges_wiki_page/actual_results/issue_7.html munges_wiki_page/actual_results/issue_8.html

munges_wiki_page/actual_results/issue_1.html: munges_wiki_page/test_cases/issue_1.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_1.html >munges_wiki_page/actual_results/issue_1.html
	diff munges_wiki_page/actual_results/issue_1.html munges_wiki_page/expected_results/issue_1.html

munges_wiki_page/actual_results/issue_2.html: munges_wiki_page/test_cases/issue_2.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_2.html >munges_wiki_page/actual_results/issue_2.html
	diff munges_wiki_page/actual_results/issue_2.html munges_wiki_page/expected_results/issue_2.html

munges_wiki_page/actual_results/issue_3.html: munges_wiki_page/test_cases/issue_3.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_3.html >munges_wiki_page/actual_results/issue_3.html
	diff munges_wiki_page/actual_results/issue_3.html munges_wiki_page/expected_results/issue_3.html

munges_wiki_page/actual_results/issue_4.html: munges_wiki_page/test_cases/issue_4.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_4.html >munges_wiki_page/actual_results/issue_4.html
	diff munges_wiki_page/actual_results/issue_4.html munges_wiki_page/expected_results/issue_4.html

munges_wiki_page/actual_results/issue_5.html: munges_wiki_page/test_cases/issue_5.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_5.html >munges_wiki_page/actual_results/issue_5.html
	diff munges_wiki_page/actual_results/issue_5.html munges_wiki_page/expected_results/issue_5.html

munges_wiki_page/actual_results/issue_6.html: munges_wiki_page/test_cases/issue_6.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_6.html >munges_wiki_page/actual_results/issue_6.html
	diff munges_wiki_page/actual_results/issue_6.html munges_wiki_page/expected_results/issue_6.html

munges_wiki_page/actual_results/issue_7.html: munges_wiki_page/test_cases/issue_6.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_7.html >munges_wiki_page/actual_results/issue_7.html
	diff munges_wiki_page/actual_results/issue_7.html munges_wiki_page/expected_results/issue_7.html

munges_wiki_page/actual_results/issue_8.html: munges_wiki_page/test_cases/issue_8.html 
	./munges_wiki_page.py munges_wiki_page/test_cases/issue_8.html >munges_wiki_page/actual_results/issue_8.html
	diff munges_wiki_page/actual_results/issue_8.html munges_wiki_page/expected_results/issue_8.html

clean:
	rm -f munges_wiki_page/actual_results/*.html
