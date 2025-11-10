### [캡슐화]

##### Public 메서드로부터 반환된 Private 배열

* Private 배열을 Public 메서드가 반환하면
  배열 주소 값이 외부 공개됨으로써 외부에서 배열 수정이 가능해지는 취약점

##### [안전하지 않은 코드]

```java
public String[] getValueField() {
	return valueField;
}
```

##### [안전한 코드]

```java
public String[] getValueField() {
    String[] valueFields = new String[valueField.length];
    for(int i=0; i<valueFields.length; i++) {
        valueFields[i] = this.valueField[i];
    }
    return valueFields;
}
```

