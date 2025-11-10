### [코드 오류]

* 일반적으로 객체가 널(Null)이 될 수 없다는 가정을 위반했을 때 발생하는 보안 취약점

##### [조치 사항]

* NPE가 발생 가능한 객체의 존재 여부를 체크 해주거나
* Objects.requireNonNull을 통해 오류 발생 시 특정 메시지를 보내어 확인할 수 있도록 한다.
  * `dataSet.setId(Objects.requiredNonNull(model, "Invalid Data").getId());`
