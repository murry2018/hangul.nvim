# Case Work

개발 과정에서 테스트하고 수정한 주요 Test case 목록

## 조합 및 매핑
- (composing) '아' + 'ㅇ' -> (composing) '앙' (종성 매핑 오류 수정)
- (composing) '파' + 'ㅎ' -> (composing) '팧' (종성 매핑 오류 수정)
- (composing) '' + Shift+'ㅔ' -> (composing) 'ㅖ' (Shift 키 매핑 오류 수정)

## 지우기 및 분해
- (composing) '가' + BS -> (composing) 'ㄱ' (단계별 분해)
- (composing) 'ㄱ' + BS -> (normal) '' (완전 삭제 시 상태 초기화)
- (composing) 'ㄲ' + BS -> (normal) '' (쌍자음은 단일 단위로 취급하여 한꺼번에 삭제)
- (composing) '쏬' + BS -> (composing) '쏘' (쌍성 종성은 한꺼번에 삭제)
- (composing) '삯' + BS -> (composing) '삭' (겹받침은 단계별 분해)

## 상태 초기화
- (normal) '가 ' + 'ㄷ' -> (composing) '가 ㄷ' (공백 입력 시 이전 조합 상태 리셋)
- (normal) '가나' + ArrowLeft + 'ㄷ' -> (composing) '가나ㄷ' (커서 이동 시 조합 상태 리셋)
- (composing) '가' + BS + BS + 'ㄷ' -> (composing) 'ㄷ' (모두 지운 후 입력 시 유령 문자 방지)

## 쌍자음
- (composing) 'ㅅ' + 'ㅅ' -> (composing) 'ㅅㅅ' (ㅅ,ㅅ 입력 시 ㅆ으로 자동 조합되지 않음)
- (normal) '' + Shift+'ㅅ' -> (composing) 'ㅆ' (쌍자음은 반드시 Shift 키로만 입력)

## 도깨비불 현상
- (composing) '앙' + 'ㅏ' -> (composing) '아아' (종성이 다음 음절의 초성으로 이동)
- (composing) '앍' + 'ㅏ' -> (composing) '알가' (겹받침의 일부가 다음 음절의 초성으로 이동)
