0. Oracle이 다양한 언어를 사용하는 데 있어서 유리하다. (e.g., JavaScript)

1. 날짜는 Date가 아닌 Varchar를 사용하는 것이 유용한 때가 많다.
   * https://stackoverflow.com/questions/4759012/when-to-use-varchar-and-date-datetime

2. Char vs Varchar
   * Char(20)으로 정의한 경우, 20 공간만큼 사용하지 않아도 미리 확보를 하여 낭비되는 공간이 생긴다.
   * Varchar(20)으로 정의한 경우, 데이터 크기 만큼만 공간을 사용한다.

3. Index는 select 할 때 사용하는 것이 좋다.

4. Auto Commit 하지 않기 ★

5. Join
   * 주로 left, inner 조인 사용
     * INNER JOIN
       * A, B 테이블 모두 있는 레코드만 조회 된다. (교집합)
     * LEFT OUTER JOIN
       * 테이블 간의 일치하는 데이터가 없는 경우 NULL로 조회된다.

6. 명령어

   * DISTINCT, SUBSTR, UPPER, CONCAT, REPLACE, LTRIM, ROUND, TRUNC 등 중요

     * SELECT DISTINCT NAME FROM TABLE;

     * SELECT ENAME, SUBSTR(ENAME, 2, 3) FROM EMP;

       * SUBSTR("문자열", "시작 위치", "길이");

     * SELECT UPPER('tistory')

     * SELECT CONCAT(COUNTRY_ID, COUNTRY_NAME) FRON COUNTRIES;

       > KRKorea
       > CNChina

     * REPLACE('문자열', '치환할 문자열', '대체할 문자열')
       REPLACE('ABCDE', 'A', '1')

       > '1BCDE'

     * LTRIM('    ABCDE    ')

       > 'ABCDE    '

     * ROUND('값', '자리수')
       ROUND(1235.443, 0)

       > 1235

     * TRUNC('값', '옵션') - 주로 소수점 절사 및 날짜의 시간을 없앨 때 사용
       TRUNC('18/11/27', 'year')

       > '18/01/01' 

   * 그룹함수

     * COUNT, AVG, SUM, MIN, MAX

7. SQL 실행순서

   1. FROM
   2. WHERE
   3. GROUP BY
   4. HAVING
   5. SELECT
   6. ORDER BY

8. 서브쿼리

   1. 괄호로 감싸서 사용한다.
   2. 단일 행 또는 복수 행 비교 연산자와 함께 사용 가능
      1. 다중행 서브쿼리의 경우 (IN, ALL과 함께 사용)
   3. Order by를 사용하지 못한다.

9. SQL 튜닝 팁(실행계획)

   * 들여쓰기 먼저, 같은 들여쓰기는 위에서 부터

   * ```
     7
     	3
     		1
     		2
     	6
     		4
     		5
     ```

   * ```
     1
     	2
     		3
     		4
     	5
     	
     3->4->2->5->1
     ```

10. 특정문자만 포함된 데이터 필터링

   * LIKE
     * 데이터 길이에 상관없는 함수: `%`
       * `WHERE NAME LIKE '최%'`
     * 데이터 길이가 일정할 때 좋은 함수: `_`
       * `WHERE NAME LIKE '최_ _';`